#USAGE: ./sync_shared_files.sh <source folder/file directory path>


# Check if the source directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# Assign the source directory to a variable
source_dir="$1"

# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' not found."
    exit 1
fi


ND=$((9 % 5))
LL=$((9 + 1))
CM=$LL"q;d"
CL=$(( $((9 / 5)) * 5))
M0=$(($ND + $CL))
M1=$(( $(( $(($ND + 1)) % 5)) + $CL))
M2=$(( $(( $(($ND + 2)) % 5)) + $CL))
M3=$(( $(( $(($ND + 3)) % 5)) + $CL))
M4=$(( $(( $(($ND + 4)) % 5)) + $CL))


# Copy files from the source directory to the remote server
sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M1.usc.edu 'mkdir -p /home/node4/shared0' && \
sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M1.usc.edu 'rm -rf /home/node4/shared0/* || true' && \
sshpass -p 'eWjEP4+6/S8w' scp -r "$source_dir"/* node4@nf$M1.usc.edu:/home/node4/shared0


sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M2.usc.edu 'mkdir -p /home/node4/shared0' && \
sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M2.usc.edu 'rm -rf /home/node4/shared0/* || true' && \
sshpass -p 'eWjEP4+6/S8w' scp -r "$source_dir"/* node4@nf$M2.usc.edu:/home/node4/shared0

sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M3.usc.edu 'mkdir -p /home/node4/shared0' && \
sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M3.usc.edu 'rm -rf /home/node4/shared0/* || true' && \
sshpass -p 'eWjEP4+6/S8w' scp -r "$source_dir"/* node4@nf$M3.usc.edu:/home/node4/shared0


sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M4.usc.edu 'mkdir -p /home/node4/shared0' && \
sshpass -p 'eWjEP4+6/S8w' ssh node4@nf$M4.usc.edu 'rm -rf /home/node4/shared0/* || true' && \
sshpass -p 'eWjEP4+6/S8w' scp -r "$source_dir"/* node4@nf$M4.usc.edu:/home/node4/shared0

sshpass -p 'eWjEP4+6/S8w' ssh netfpga@nf$M0.usc.edu 'mkdir -p /home/netfpga/shared0' && \
sshpass -p 'eWjEP4+6/S8w' ssh netfpga@nf$M0.usc.edu 'rm -rf /home/netfpga/shared0/* || true' && \
sshpass -p 'eWjEP4+6/S8w' scp -r "$source_dir"/* netfpga@nf$M0.usc.edu:/home/netfpga/shared0

