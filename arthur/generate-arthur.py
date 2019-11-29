#************************************************************************
#
#   generate-arthur.py
#
#   Generate the Arthur 1.20 Domesday build environment
#   Copyright (C) 2019 Simon Inns
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 3 of the
#   License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Email: simon.inns@gmail.com
#
#************************************************************************/

import shutil
import os
import errno
import fnmatch

# Perform a recursive copy of folders and files
def copy_recursively(src, dst):
    try:
        shutil.copytree(src, dst)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise

# Apply file type based on file extension:
# .bcpl = &fff (ASCII text)
# .asm = &fff
# .obey = &feb (Obey command file)
# .txt = &fff
def apply_filetypes(directory):
    for subdir, dirs, files in os.walk(directory):
        for filename in files:
            # .bcpl files should have type &fff
            if filename.find('.bcpl') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".bcpl",",fff"))
                os.rename(src, dst) # Rename the file

            # .obey files should have type &feb
            if filename.find('.obey') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".obey",",feb"))
                os.rename(src, dst) # Rename the file

            # .comm files should have type &ffe
            if filename.find('.comm') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".comm",",ffe"))
                os.rename(src, dst) # Rename the file

            # .asm files should have type &fff
            if filename.find('.asm') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".asm",",fff"))
                os.rename(src, dst) # Rename the file

# Find and replace tokens recursively in files
def find_and_replace(directory, find, replace, filePattern):
    for path, dirs, files in os.walk(os.path.abspath(directory)):
        for filename in fnmatch.filter(files, filePattern):
            filepath = os.path.join(path, filename)
            with open(filepath) as f:
                s = f.read()
            s = s.replace(find, replace)
            with open(filepath, "w") as f:
                f.write(s)

# Replace a token with an actual directory location
def replace_token(token, target_dir):
    # Find and replace the token in .bcpl files
    find_and_replace("./root", token, target_dir, "*.bcpl")

    # Find and replace the token in .comm files
    find_and_replace("./root", token, target_dir, "*.comm")

    # Find and replace the token in .obey files
    find_and_replace("./root", token, target_dir, "*.obey")

    # Find and replace the token in .asm files
    find_and_replace("./root", token, target_dir, "*.asm")

# Main program -----------------------------------------------------------------------

# Ensure that the target directories exists before copying
print("Creating root directory...")
if os.path.exists("./root"):
    # If the directory already exists, remove it and recreate it
    shutil.rmtree("./root")
    os.mkdir("./root")
else:
    os.mkdir("./root")

print("Creating source directory...")
if os.path.exists("./root/src"):
    # If the directory already exists, remove it (it is recreated by the copy below)
    shutil.rmtree("./root/src")

print("Creating library directory...")
if os.path.exists("./root/library"):
    # If the directory already exists, remove it (it is recreated by the copy below)
    shutil.rmtree("./root/library")

print("Creating headers directory...")
if os.path.exists("./root/alib"):
    # If the directory already exists, remove it (it is recreated by the copy below)
    shutil.rmtree("./root/alib")

print("Creating log directory...")
if os.path.exists("./root/log"):
    # If the directory already exists, remove it and recreate it
    shutil.rmtree("./root/log")
    os.mkdir("./root/log")
else:
    os.mkdir("./root/log")



# Make a copy of the source code in the target directory
print("Copying source files...")
copy_recursively("../build/src", "./root/src")

# Make a copy of the libaries in the target directory
print("Copying library files...")
copy_recursively("../build/library", "./root/library")

# Make a copy of the headers in the target directory
print("Copying header files...")
copy_recursively("../build/headers", "./root/alib")

# Make a copy of the boot scipt in the target directory
print ("Copying boot script")
shutil.copy("../build/Boot.comm", "./root/!Boot.comm")



# Find and replace the tokens
target_root_dir = "ADFS::4.$"
target_src_dir = target_root_dir + ".src"
target_log_dir = target_root_dir + ".log"
target_library_dir = target_root_dir + ".library"
target_header_dir = target_root_dir + ".alib"

print("Setting root directory in files...")
replace_token("<$ROOTDIR>", target_root_dir)

print("Setting source directory in files...")
replace_token("<$SRCDIR>", target_src_dir)

print("Setting log directory in files...")
replace_token("<$LOGDIR>", target_log_dir)

print("Setting library directory in files...")
replace_token("<$LIBDIR>", target_library_dir)

print("Setting header directory in files...")
replace_token("<$HEADERDIR>", target_header_dir)



# Apply Archimedes file types
print("Replacing file extensions with RISC OS file types...")
apply_filetypes("./root")



# Remove unwanted files from target
print("Removing unwanted files...")
for root, dirs, files in os.walk("./root"):
        for currentFile in files:
            exts = ('.md')
            if currentFile.lower().endswith(exts):
                os.remove(os.path.join(root, currentFile))


print("Done")
