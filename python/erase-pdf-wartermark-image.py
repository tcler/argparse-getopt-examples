#!/usr/bin/env python3
#ref: https://github.com/pymupdf/PyMuPDF-Utilities/blob/master/image-replacement/remover.py
#required pkgs on Fedora: mupdf python3-PyMuPDF

import fitz  #python3 pymupdf module
import io,os,sys
from PIL import Image

usage = f"Usage: {sys.argv[0]} <pdf-file-with-wartermark-image> [-h] [-d|-debug] [-n<page-index>] [-c<wartermark-index>]"
path = None
wm_occurrence = 99.90
nowm_occurrence = 100 - wm_occurrence
base_page_idx = 0
wartermark_idx = -1
debug = 0
for arg in sys.argv[1:]:
    if (arg[0] != '-'):
        if (path == None): path = arg
    else:
        if (arg[:2] == "-h"):
            print(usage); exit(0)
        elif (arg[:2] == "-d"):
            debug += arg.count('d')
        elif (arg[:2] == "-n"):
            base_page_idx = int(arg[2:])
        elif (arg[:2] == "-c"):
            wartermark_idx = int(arg[2:])
if (path == None):
    print(usage)
    exit(1)
if (not os.path.isfile(path)):
    print(f"[ERROR] file {path} not exist or is not a file.")
    exit(1)

pdfname = path.split(".")[0]

def imginfo_cmp(img1, img2):
    if (img1[2] == img2[2] and img1[3] == img2[3] and
        img1[4] == img2[4] and img1[5] == img2[5] and img1[8] == img2[8]):
        return True
    else:
        return False

def imgfobj_cmp(imgf_obj1, imgf_obj2):
    #if (len(imgf_obj1['image']) == len(imgf_obj2['image'])):
    if ((imgf_obj1['image']) == (imgf_obj2['image'])):
        return True
    else:
        return False

def percent_of(num_a, num_b):
    return round(((num_a / num_b) * 100.0), 2)

from collections import namedtuple
WMImage = namedtuple('WMImage', ['info', 'imgf', 'pct'])

pdf = fitz.open(path)
npages = len(pdf)
if (base_page_idx < 0):
    base_page_idx += npages
    if (base_page_idx < 0): base_page_idx = 0
if (base_page_idx > (npages-1)):
    print(f"[WARN] base-page-idx {base_page_idx} beyond the max index, use the max({npages-1}) instead")
    base_page_idx = npages - 1
base_page = pdf[base_page_idx]
base_imgs = base_page.get_images()
if (debug > 1):
    print(f"[DEBUG] base_page_imgs {base_imgs}")

#scan and detect the wartermark image. here we assume:
#if an image appears in all pages, intend it's wartermark image
#Note: if this assumption does not hold, more code & options need
#to be added to allow the user to specify the 'base_page_idx' and
#frequency of occurrence of warter-mark in pages 'wm_occurrence'
print(f"[INFO] scanning and detecting wartermark image in pdf {path} ...")
wm_images = [] #yes, I found there are more than 1 image match, don't know why
for baseimg in base_imgs:
    baseimg_obj = pdf.extract_image(baseimg[0])
    wmc, nowmc = 0, 0
    for index in range(npages):
        page = pdf[index]
        hit = 0
        for img in page.get_images():
            if (imginfo_cmp(img, baseimg)):
                imgf_obj = pdf.extract_image(img[0])
                if (imgfobj_cmp(imgf_obj, baseimg_obj)):
                    hit = 1
                    break
        if (hit):
            wmc += 1
        else:
            nowmc += 1
        if (percent_of(nowmc, npages) > nowm_occurrence):
            break
    pct = percent_of(wmc, npages)
    if (pct >= wm_occurrence):
        wm_images.append(WMImage(baseimg, baseimg_obj, pct))

if (len(wm_images) == 0):
    print(f"[WARN] did not find wartermark image in {path}")
    exit(1)

nwmimg = len(wm_images)
print(f"[INFO] detected {nwmimg} wartermark image[s]:")
for i in range(nwmimg):
    info, imgf, pct = wm_images[i].info, wm_images[i].imgf, wm_images[i].pct
    print(f"[INFO] wartermark image {i}:\n[INFO] |-> info: {info}\n[INFO] |-> data-size: {len(imgf['image'])}\n[INFO] `-> occurrence: {pct}")

#generate wartermark image file[s] for debug
if (debug):
    for i in range(nwmimg):
        info, imgf = wm_images[i].info, wm_images[i].imgf
        wmimg_bytes = imgf["image"] #get wm-image data/bytes
        wmimg_ext = imgf["ext"] #get wm-image extension/type
        wmimgf_path = f"{path.replace('.pdf','')}-wartermark-image{i}.{wmimg_ext}"
        print(f"[INFO] generate warter makr image file: {wmimgf_path} ...")
        wmimgf = Image.open(io.BytesIO(wmimg_bytes))
        wmimgf.save(wmimgf_path)

if (wartermark_idx < 0):
    wartermark_idx += nwmimg
    if (wartermark_idx < 0): wartermark_idx = 0
if (wartermark_idx > (nwmimg-1)):
    print(f"[WARN] wartermark-idx {wartermark_idx} beyond the max index, use the max({nwmimg-1}) instead")
    wartermark_idx = nwmimg - 1
print(f"[INFO] erase wartermark image {wartermark_idx} from pages ...")
# make a small 100% transparent pixmap (of just any dimension)
pix = fitz.Pixmap(fitz.csGRAY, (0, 0, 1, 1), 1)
pix.clear_with()  # clear all samples bytes to 0x00
wm_image, wm_imagef_obj = wm_images[wartermark_idx].info, wm_images[wartermark_idx].imgf
for index in range(npages):
    page = pdf[index]
    imgs = page.get_images()
    if (debug > 1 and index == base_page_idx):
        print(f"[DEBUG] base_page_imgs {imgs}")
    if (debug > 2):
        print(f"page{index}: {imgs}")

    wmimg_xrefs = []
    for img in imgs:
        if (imginfo_cmp(img, wm_image)):
            imgf_obj = pdf.extract_image(img[0])
            if (imgfobj_cmp(imgf_obj, wm_imagef_obj)):
                wmimg_xrefs.append(img[0])

    # insert new image just anywhere
    page.clean_contents()  # unify page's /Contents into one
    new_xref = page.insert_image(page.rect, pixmap=pix)

    # copy over definition and stream of new image
    for img_xref in wmimg_xrefs:
        pdf.xref_copy(new_xref, img_xref)

    # there now is a second /Contents object, showing new image
    cont_xrefs = page.get_contents()

    # make sure that new /Contents(cont_xrefs[1]) is forgotten
    page.set_contents(cont_xrefs[0])
    page.clean_contents()  # unify page's /Contents into one again

new_path = f"{path.replace('.pdf','')}-no-wartermark.pdf"
print(f"[INFO] generate new pdf: {new_path} ...")
pdf.ez_save(new_path, garbage=4)

import subprocess
subprocess.run(["ls", "-lh", new_path, path])
