el-qrencode 1.0-alpha
=====================

This is a QR code generator for Emacs, written in Emacs Lisp. It's a
CommonLISP-to-EmacsLISP port of the cl-qrencode package by jnjcc, see
`Copyright and License` at bottom for more details.

![usage example](https://github.com/thesoftwarebin/el-qrencode/blob/master/README.example.png)

Please consider this EmacsLISP version as an alpha-quality hobby
project: future version may add, rename or remove functions. 

If you like it and have bugfixes or enhancements to contribute, please
do! Patches and forks are more than welcome, please read also the
`Proposed/Needed Future Enhancements` section below.

Usage example
-------------

In the following the Emacs keyboard notation will be used: for example
`RET` means press Return, `M-x` means press Alt+x, `C-x` means press
Ctrl+x. For further details see
[the Emacs manual, section User Input](https://www.gnu.org/software/emacs/manual/html_node/emacs/User-Input.html).

Here's a basic usage example:

- start Emacs
- `M-x cd RET <qrencode directory here> RET`
- `M-x load-file RET load.el RET`
- put the cursor in an empty buffer (like `*scratch*`) and
type some example text like `hello qrencode!`.
- mark the `hello qrencode!` with the mouse and type
  `M-x qrencode-region RET`: a QRcode has been generated
  in results buffer `*qrcode*` using ASCII characters
- view the results buffer by typing `C-x b *qrcode*`,
  maybe use zoom-out (`C-x C-+`) to make it fit in your
  window
  
Configuration
-------------

You may tweak the `(defvar ...)` statements at top of
`emacs-commands.el`.  Most variables are rather self-explanatory,
except the ones used for ASCII representation of the single
black/white QR cell.

Every cell is `qrencode-hzoom` characters large and `qrencode-vzoom`
characters tall. I've set a default of `qrencode-hzoom`=2 because my
default fonts are rather tall.

Dependencies
------------

I tried to keep them to the bare minimum. You need to have at least
the `cl` package. It works properly on Emacs 24.4, it's untested on
other versions.

Proposed/Needed Future Enhancements
-----------------------------------

- better documentation of both the private and interactive functions
- code refactoring: decorate private functions and classes with the
  `qrencode--` prefix
- code refactoring: remove recursive functions (they forced me to
  tweak `max-specpdl-size` and `max-lisp-eval-depth` in `load.el`)
- code refactoring: turn this into an Emacs package, so it might work
  with `M-x list-packages RET` and Emacs repositories (maybe
  [Melpa](http://melpa.org) or
  [Marmalade](https://marmalade-repo.org/))
- enhancement: generate an image containing the QR code; start with
  XPM format (built-in support in Emacs), add other formats if
  possible and not too hard (SVG?)
- enhancement: build a separate module for Org mode that turns a
  timestamped Org task into a QRcode calendar event
- (other suggestions welcome)

Copyright and License
---------------------

Original Common Lisp version:
Copyright (c) 2011-2014 jnjcc, [Yste.org](http://www.yste.org)

Port to Emacs Lisp:
Copyright (c) 2015 Andrea Rossetti (http://andrear.altervista.org)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version. Refer to the COPYING file in this same directory.
