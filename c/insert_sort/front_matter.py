from IPython.display import display, Markdown, Latex
import tikzplotlib
import os
import matplotlib.pyplot as plt
import matplotlib as mpl
mpl.rcParams['text.usetex'] = True

def footnoter(the_notebook,the_kernel):
  return Latex("\\footnotetext{"+
    "Python code in this section was generated from a Jupyter notebook "+
    "named \\mintinline{bash}{" f"{the_notebook}"+".ipynb} with a \\texttt{"+
    f"{the_kernel}"+"} kernel.}")

def pxfer( # pgf or pdf
  fig_name,
  filename,
  draft_mode=False,
  save_dir='.',
  graphics_dir='source',
  linewidth=1,
  height_fraction=.5,
  output_type='pgf', # or pdf
  figure='figure', # figure or nofloatfig or marginupfig or margindownfig or fullwidthfig
  caption='', 
  label=None,
  counter=None,
  **kwargs # keyword arguments for savefig
):
  if draft_mode:
    print('draft mode ... no figure saved')
  else:
    if counter is None:
      pxfer.counter += 1
    else:
      pxfer.counter = counter
    if label is None:
      label = filename+f"_{pxfer.counter}"
    filename_sans = os.path.splitext(filename)[0]
    filename_counter = filename_sans+"_"+str(pxfer.counter)+'.'+output_type
    #
    if output_type is 'pgf':
      mpl.use("pgf")
      pgf_with_pdflatex = {
        "pgf.texsystem": "pdflatex",
        "pgf.preamble": [
           r"\usepackage[T1]{fontenc}",
           r"\usepackage[utf8]{inputenc}",
           r"\DeclareUnicodeCharacter{2212}{\textendash}",
           r"\usepackage{cmbright}",
        ]
      }
      mpl.rcParams.update(pgf_with_pdflatex)
    elif output_type is 'pdf':
      mpl.use("module://ipykernel.pylab.backend_inline")
    else: 
      error('output_type {output_type} not supported')
    #
    fig_name.savefig(
      save_dir+'/'+filename_counter,
      texsystem='pdflatex',
      **kwargs
    )
    mpl.use("module://ipykernel.pylab.backend_inline")
    if output_type is 'pgf':
      graphics_command = "\\input{"
    else:
      graphics_command = "\\includegraphics[width="+f"{linewidth}"+"\\linewidth]{"
    if (figure is 'figure' or figure is True):
      wrapper_before = "\\begin{figure} \n"+"\\centering \n"
      wrapper_after = "\\caption{"+f"{caption}"+"} \n"+"\\label{"+f"{label}"+"} \n"+"\\end{figure}\n"
    elif figure is 'nofloatfig':
      wrapper_before = "\\begin{nofloatfig}["+caption+"] \n"
      wrapper_after = "\\end{nofloatfig}\n"
    elif (figure is 'marginupfig' or figure is False):
      wrapper_before = "\\marginnoteupresize{\n"
      wrapper_after = "}{\\captionof{figure}{"+f"{caption}"+"} \n"+"\\label{"+f"{label}"+"}"+"}"
    elif figure is 'margindownfig':
      wrapper_before = "\\marginnote{\n"
      wrapper_after = "\\captionof{figure}{"+f"{caption}"+"} \n"+"\\label{"+f"{label}"+"}"+"}"
    elif figure is 'fullwidthfig':
      wrapper_before = "\\begin{fullwidthfig} \n"+"\\centering \n"
      wrapper_after = "\\caption{"+f"{caption}"+"} \n"+"\\label{"+f"{label}"+"} \n"+"\\end{fullwidthfig}\n"

    return Latex(wrapper_before+f"{graphics_command}"+f"{graphics_dir}/{filename_counter}"+"}\n"+f"{wrapper_after}")
pxfer.counter = 0