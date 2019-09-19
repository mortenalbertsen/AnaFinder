# Copy of file found in /Users/Morten/Library/Containers/Albertsen.AnaFinder/Data/Documents
import hashlib
import sys

def hash_file(filepath):
"""
Outputs the hash for every line in file given as argument to hasher.py
Example invocation, assuming a file test.txt exists in same folder as hasher.py:
python3 hasher.py test.txt
"""
    with open(filepath) as file:
        for line in file:
            sick = line[:-1]
            print(hashlib.md5(sick.encode()).hexdigest())

if __name__ == "__main__":
    hash_file(sys.argv[1])
    
