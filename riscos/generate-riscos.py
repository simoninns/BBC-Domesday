#************************************************************************
#
#   generate-riscos.py
#
#   Generate the Arthur/RISC OS 2 Domesday build environment
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
import argparse

# Perform a recursive copy of folders and files
def copy_recursively(src, dst):
    try:
        shutil.copytree(src, dst)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise

# Apply file type based on file extension:
# .b = &fff (ASCII text)
# .h = &fff 
# .a = &fff
# .obey = &feb (Obey command file)
# .txt = &fff
def apply_filetypes(directory):
    for subdir, dirs, files in os.walk(directory):
        for filename in files:
            # .b files should have type &fff
            if filename.find('.b') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".b",",fff"))
                os.rename(src, dst) # Rename the file

            # .a files should have type &fff
            if filename.find('.a') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".a",",fff"))
                os.rename(src, dst) # Rename the file

            # .h files should have type &fff
            if filename.find('.h') > 0:
                src = os.path.join(subdir, filename)
                dst = os.path.join(subdir, filename.replace(".h",",fff"))
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
    # Find and replace the token in .b files
    find_and_replace("./root", token, target_dir, "*.b")

    # Find and replace the token in .a files
    find_and_replace("./root", token, target_dir, "*.a")

    # Find and replace the token in .h files
    find_and_replace("./root", token, target_dir, "*.h")

    # Find and replace the token in .comm files
    find_and_replace("./root", token, target_dir, "*.comm")

    # Find and replace the token in .obey files
    find_and_replace("./root", token, target_dir, "*.obey")

# Main program -----------------------------------------------------------------------

# Deal with command line arguments
parser = argparse.ArgumentParser(description="Arthur/RISC OS 2 build environment generator")
parser.add_argument("--target", default="ADFS::4.$", type=str, help="Specify the target ADFS folder (Default is ADFS::4.$)")
args = parser.parse_args()
target_root_dir = args.target
print("Target ADFS folder is ", target_root_dir)


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
if os.path.exists("./root/headers"):
    # If the directory already exists, remove it (it is recreated by the copy below)
    shutil.rmtree("./root/headers")

print("Creating build directory...")
if os.path.exists("./root/build"):
    # If the directory already exists, remove it (it is recreated by the copy below)
    shutil.rmtree("./root/build")

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
copy_recursively("../build/riscos/library", "./root/library")

# Make a copy of the headers in the target directory
print("Copying header files...")
copy_recursively("../build/riscos/headers", "./root/headers")

# Make a copy of the build scripts in the target directory
print("Copying build files...")
copy_recursively("../build/riscos/build", "./root/build")



# Find and replace the tokens
target_src_dir = target_root_dir + ".src"
target_log_dir = target_root_dir + ".log"
target_library_dir = target_root_dir + ".library"
target_header_dir = target_root_dir + ".headers"
target_build_dir = target_root_dir + ".build"

print("Setting root directory in files...")
replace_token("<$ROOTDIR>", target_root_dir)

print("Setting source directory in files...")
replace_token("<$SRCDIR>", target_src_dir)

print("Setting log directory in files...")
replace_token("<$LOGDIR>", target_log_dir)

print("Setting library directory in files...")
replace_token("<$LIBDIR>", target_library_dir)

print("Setting headers directory in files...")
replace_token("<$HEADERDIR>", target_header_dir)

# Update the GET include directives in the source code to RISC OS style paths
print("Setting GET H/ in files...")
replace_token("get \"H/", "get \"" + target_src_dir + ".H.")

print("Setting GET GH/ in files...")
replace_token("get \"GH/", "get \"" + target_src_dir + ".GH.")

print("Removing .h extension from includes in files...")
replace_token(".h\"", "\"")

# Remove the .h filename extension from all GET include directive paths


print("Setting build directory in files...")
replace_token("<$BUILDDIR>", target_build_dir)



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
