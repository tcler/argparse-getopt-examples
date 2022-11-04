#!/usr/bin/env python3
#ref: https://github.com/pymupdf/PyMuPDF-Utilities/blob/master/image-replacement/remover.py

import fitz  #python3 pymupdf module
import io,os,sys
from PIL import Image

path = sys.argv[1]
pdfname = path.split(".")[0]
pdf = fitz.open(path)

for page_index in range(len(pdf)):
    #print(f"page-{page_index}:")
    page = pdf[page_index]
    page.clean_contents()
    imgs = page.get_images()
    #print(imgs)
    wmimg_xrefs = []
    for img in imgs:
        if (img[3] == 990):
            wmimg_xrefs.append(img[0])
            break

    # make a small 100% transparent pixmap (of just any dimension)
    pix = fitz.Pixmap(fitz.csGRAY, (0, 0, 1, 1), 1)
    pix.clear_with()  # clear all samples bytes to 0x00

    # insert new image just anywhere
    new_xref = page.insert_image(page.rect, pixmap=pix)

    # copy over definition and stream of new image
    for img_xref in wmimg_xrefs:
        pdf.xref_copy(new_xref, img_xref)

    # there now is a second /Contents object, showing new image
    cont_xrefs = page.get_contents()

    # make sure that new /Contents(cont_xrefs[1]) is forgotten again
    page.set_contents(cont_xrefs[0])
    page.clean_contents()
pdf.ez_save(f"{path.replace('.pdf','')}-no-wartermark.pdf", garbage=4)
