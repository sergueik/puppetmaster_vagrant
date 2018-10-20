import os
import sys
import shutil
from shutil import copyfile
import fileinput

# Full path of where this python script currently is
CURRENT_DIR = os.path.abspath(os.path.dirname(__file__))

# Where you want to store the tests from here
TESTS_DIR="Tests"

# Where the tests are copied to for execution and then deleted after success
SPEC_DIR="spec/localhost/"

src=os.path.join(CURRENT_DIR, TESTS_DIR)
dest=os.path.join(CURRENT_DIR, SPEC_DIR)

# Init serverspec directory
def init():
    os.system('printf 12 | serverspec-init ')
    os.system('rm -f spec/localhost/sample_spec.rb')

def copytree(src, dst, symlinks=False, ignore=None):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            copytree(s, d, symlinks, ignore)
        else:
            if not os.path.exists(d) or os.stat(s).st_mtime - os.stat(d).st_mtime > 1:
                shutil.copy2(s, d)

def rakefile():
    # Modify Rakefile to read all *.rb
    f = open("Rakefile",'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace("*_spec.rb","*.rb")
    f = open("Rakefile",'w')
    f.write(newdata)
    f.close()

def rspecfile():
    # Modify .rspec so you don't require require 'spec_helper' at the top of each test
    with open(".rspec", "a") as rspecfile:
        rspecfile.write("--require spec_helper")

def runtests():
    os.environ["CURRENT_DIR"] = CURRENT_DIR
    os.system('cd $CURRENT_DIR && rake spec')

def cleanup():
    os.system('rm -rf .rspec Rakefile spec')

def main():
    try:
        init()
        copytree(src, dest)
        rakefile()
        rspecfile()
        runtests()
        cleanup()
    except OSError as detail:
        cleanup()
        print detail

main()
