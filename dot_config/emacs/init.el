;;; init.el --- User Emacs configuration -*- lexical-binding: t -*-

;; Never let Custom write to a file: all configuration lives in dotEmacs.org,
;; so anything set through the Customize UI is discarded instead of lingering.
(setq custom-file null-device)
;; Saving still tries to write that file and fails ("not a regular file:
;; /dev/null"). package.el saves `package-selected-packages' right after
;; installing a package, so the first daemon start after adding a package
;; exits with an error. Make saving a no-op: values still apply for the session.
(advice-add 'custom-save-all :override #'ignore)

(require 'package)
;; Add MELPA to the packages list
(add-to-list 'package-archives
 	     '("melpa" . "https://melpa.org/packages/"))
;; Highest number gets priority (what is not mentioned has priority 0)
(setq package-archive-priorities
      '(("gnu" . 2)
        ("nongnu" . 1)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built in since Emacs 29.
(require 'use-package)
(setq use-package-always-ensure t)

(use-package org :ensure nil)
(org-babel-load-file (locate-user-emacs-file "dotEmacs.org"))

;;; init.el ends here
