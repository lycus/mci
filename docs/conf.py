import sys, os

extensions = ['sphinx.ext.todo']

templates_path = ['_templates']
exclude_patterns = ['_build']

project = u'Managed Compiler Infrastructure'
copyright = u'The Lycus Foundation'

version = '1.0'
release = '1.0'

source_suffix = '.rst'
master_doc = 'index'

pygments_style = 'sphinx'
highlight_language = 'd'

html_theme = 'default'
html_static_path = ['_static']
htmlhelp_basename = 'MCIdoc'

latex_documents = [
  ('index', 'MCI.tex', u'Managed Compiler Infrastructure',
   u'The Lycus Foundation', 'manual'),
]

man_pages = [
    ('index', 'mci', u'Managed Compiler Infrastructure',
     [u'The Lycus Foundation'], 1)
]

epub_title = u'Managed Compiler Infrastructure'
epub_author = u'The Lycus Foundation'
epub_publisher = u'The Lycus Foundation'
epub_copyright = u'The Lycus Foundation'
