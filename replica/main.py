import threading
from datetime import datetime
import json
import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import paramiko

last_modify_time = datetime.now()
lock = threading.Lock()

with open('config.json') as config_file:
    config = json.load(config_file)

LOCAL_DIRECTORY = config['local_directory']
REMOTE_MACHINES = config['remote_machines']


class SFTPClientSupportsDir(paramiko.SFTPClient):
    def put_dir(self, source, target):
        """ Uploads the contents of the source directory to the target path. The
            target directory needs to exist. All subdirectories in source are
            created under target.
        """
        for item in os.listdir(source):
            if os.path.isfile(os.path.join(source, item)):
                self.put(os.path.join(source, item), '%s/%s' % (target, item))
            else:
                self.mkdir('%s/%s' % (target, item), ignore_existing=True)
                self.put_dir(os.path.join(source, item), '%s/%s' % (target, item))

    def mkdir(self, path, mode=511, ignore_existing=False):
        """ Augments mkdir by adding an option to not fail if the folder exists  """
        try:
            super(SFTPClientSupportsDir, self).mkdir(path, mode)
        except IOError:
            if ignore_existing:
                pass
            else:
                raise


class ChangeHandler(FileSystemEventHandler):
    def on_modified(self, event):
        global last_modify_time
        global lock
        lock.acquire()
        try:
            last_modify_time = datetime.now()
        finally:
            lock.release()


def create_new_version_and_symlink(ssh, file_path, remote_storage, remote_path):
    """Uploads the new file to a versioned directory and updates the symbolic link."""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    versioned_dir = os.path.join(remote_storage, f"version_{timestamp}")
    symlink = os.path.join(remote_path)

    # Create a new versioned directory
    ssh.exec_command(f'mkdir -p {versioned_dir}')

    # Transfer the file
    scp = SFTPClientSupportsDir.from_transport(ssh.get_transport())
    remote_file_path = os.path.join(versioned_dir)
    scp.put_dir(file_path, remote_file_path)
    scp.close()

    # Update the symbolic link to point to the new version
    ssh.exec_command(f'ln -sfn {versioned_dir} {symlink}')


def scp_transfer(file_path, remote_host, remote_username, remote_password, remote_storage, remote_path):
    """Establishes an SSH connection and calls the function to handle versioning and symlinking."""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(remote_host, username=remote_username, password=remote_password)
        create_new_version_and_symlink(ssh, file_path, remote_storage, remote_path)
    except Exception as e:
        print(f"Error transferring file to {remote_host}: {e}")
    finally:
        ssh.close()


if __name__ == "__main__":
    event_handler = ChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, path=LOCAL_DIRECTORY, recursive=True)
    observer.start()
    try:
        while True:
            input("Press enter to transfer, or Ctrl+c to quit.")
            print(f"Performing transfer.")
            for machine in REMOTE_MACHINES:
                scp_transfer(file_path=LOCAL_DIRECTORY,
                             remote_host=machine['host'],
                             remote_username=machine['username'],
                             remote_password=machine['password'],
                             remote_storage=machine['storage_directory'],
                             remote_path=machine['directory'])
    except KeyboardInterrupt:
        observer.join()
        quit(0)
