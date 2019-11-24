#************************************************************************
#
#   generate-a440.py
#
#   Generate the A440/1 Domesday build environment
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

# Remove unwanted files from path
def remove_unwanted_files(path):
    for root, dirs, files in os.walk(path):
        for currentFile in files:
            exts = ('.bcpl', '.obey')
            if not currentFile.lower().endswith(exts):
                os.remove(os.path.join(root, currentFile))

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

# Main program
target_riscos_dir = "IDEFS::Develop.$.Domesday"

# Ensure that the target directory exists before copying
print("Creating top level ARC directory...")
if os.path.exists("./ARC"):
    # If the directory already exists, remove it and recreate it
    shutil.rmtree("./ARC")

# Make a copy of the source code in the target directory
print("Copying source files to ARC...")
copy_recursively("../src", "./ARC")

# Remove any source files we don't need
print("Removing unwanted files from ARC..")
remove_unwanted_files("./ARC")

# Find and replace the <$ROOTDIR> token in .bcpl files
print("Setting root directory in .bcpl files...")
find_and_replace("./ARC", "<$ROOTDIR>", target_riscos_dir + ".ARC", "*.bcpl")

# Find and replace the <$ROOTDIR> token in .obey files
print("Setting root directory in .obey files...")
find_and_replace("./ARC", "<$ROOTDIR>", target_riscos_dir + ".ARC", "*.obey")

# Apply Archimedes file types
print("Replacing file extensions with RISC OS file types...")
apply_filetypes("./ARC")

print("Done")