#!/usr/bin/env python3
#function: detect and remove wartermark in marked-contant from pdf, just for fun
#auther: <yin-jianhong@163.com>
#ref: https://github.com/pymupdf/PyMuPDF/discussions/1855
#required pkgs on Fedora: mupdf python3-PyMuPDF

import fitz  #python3 pymupdf module
import io,os,sys

usage = f"Usage: {sys.argv[0]} <pdf-file-with-wartermark-in-marked-content> [-h] [-d|-debug] [-p<page-idx>]"
path = None
page_idx = None
debug = 0
for arg in sys.argv[1:]:
    if (arg[0] != '-'):
        if (path == None): path = arg
    else:
        if (arg[:2] == "-h"):
            print(usage); exit(0)
        elif (arg[:2] == "-d"):
            debug += arg.count('d')
        elif (arg[:2] == "-p"):
            page_idx = int(arg[2:] if arg[2:] else 0)
if (path == None):
    print(usage)
    exit(1)
if (not os.path.isfile(path)):
    print(f"[ERROR] file {path} not exist or is not a file.")
    exit(1)

pdfname = path.split(".")[0]

pdf = fitz.open(path)
npages = len(pdf)
if (page_idx and page_idx < 0):
    page_idx += npages
    if (page_idx < 0): page_idx = 0
if (page_idx and page_idx > (npages-1)):
    print(f"[WARN] page-idx {page_idx} beyond the max index, use the max({npages-1}) instead")
    page_idx = npages - 1

print(f"[INFO] scanning and detecting wartermark in marted-content in file {path} ...")
idxrange = range(npages)
if page_idx:
    idxrange = [page_idx]
hit = 0
for idx in idxrange:
    page = pdf[idx]
    page.clean_contents()
    xref = page.get_contents()[0]            # get xref of resulting /Contents object
    cont = bytearray(page.read_contents())   # read the contents source as a (modifyable) bytearray
    if cont.find(b"/Subtype/Watermark") > 0: # this will confirm a marked-content watermark is present
        hit += 1
    else:
        if debug > 0:
            print(f"[DEBUG] page-{idx}: did not find wartermark in marked-content")
        continue

    if debug > 0:
        print(f"[DEBUG] page-{idx}: detected \033[34mwartermark in marked-content\033[0m, removing")
    while True:
        i1 = cont.find(b"/Artifact") # start of definition
        if i1 < 0: break             # none more left: done
        i2 = cont.find(b"EMC", i1)   # end of definition
        if debug > 0:
            print(f"[DEBUG]   remove: {cont[i1-2 : i2+3]}")
        cont[i1-2 : i2+3] = b""      # remove the full definition source "q ... EMC"
    pdf.update_stream(xref, cont)    # replace the original source

if hit > 0:
    if debug == 0:
        print(f"[INFO] detected \033[34mwartermark in marked-content\033[0m in file {path}, removeing them ...")
else:
    print(f"[WARN] did not find any wartermark in marked-content in file {path}")
    exit(0)

new_path = f"{path.replace('.pdf','')}-no-wartermark.pdf"
print(f"[INFO] generate new pdf: {new_path} ...")
pdf.ez_save(new_path, garbage=4)

import subprocess
subprocess.run(["ls", "-lh", new_path, path])
