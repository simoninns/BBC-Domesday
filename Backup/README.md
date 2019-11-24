# Backup
This directory contains back-ups from the original Acorn A500 containing the source code.

The files are as follows:

## A500_Arthur_ROM.zip
The original Arthur 1.20 ROM (this ROM image is zipped and will need to be unzipped on a modern PC before use)

## A500EXALL.zip
A full *EX listing of the original hard drive contents

## A500Logica_MFM_ADFS.zip
This hard drive image can be directly mounted using ArcEm.  To use the image simply copy it into the correct directory and alter the ArcEm hard drive configuration to use the following parameters (for the drive geometry):

    MFM disc
    1 612 4 32 256

## LogicaA500_hostfs_zip.zip
This archive is provided for browsing the hard drive’s files on a modern PC and also includes host FS style filenames for compatibility with various Acorn emulators.

## LogicaA500_sparkFS_archive.zip
A SparkFS archive created on a RISC OS 3.10 machine.  Please note that the time-stamps of the files has been preserved however, the time-stamps of the directories was replaced by SparkFS during archiving.  This compression format is not compatible with modern PCs (and is a proprietary closed-source format) and is therefore only suitable for use on a RISC OS machine.  In order to ease downloading of the sparkFS image it has been placed in a compressed zip archive.  You will need to decompress the zip archive on a modern PC and then use SparkFS or SparkPlug on a RISC OS machine to decompress the actual files.

## LogicaA500_riscos_zip.zip
This archive is the same as the sparkFS archive above (and should be decompressed under RISC OS to preserve the filetypes) however the archive is only zipped (avoiding the need to use SparkFS).


