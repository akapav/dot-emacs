;; packages
(setq package-archives '(("gnu"       . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa"     . "http://melpa.milkbox.net/packages/")))

(require 'package)
(package-initialize)

;; uncategorized
(show-paren-mode t)
(mouse-wheel-mode t)

(global-set-key [select] 'dabbrev-expand)
;;(global-set-key [select] 'hippie-expand)

(setq
  backup-directory-alist    '(("." . "~/.emacs.d/backups"))
  x-select-enable-clipboard t)

;; elisp
(defun apply-region-or-line (fn)
  (let ((bounds
     (if (use-region-p)
         (list (region-beginning) (region-end))
       (list (line-beginning-position) (line-end-position)))))
    (apply fn bounds)))

;; customizations
(setq custom-file "~/.emacs.d/cust.el")
(load custom-file)

;; carret
(defun set-cursor-according-to-mode ()
 (cond
   (buffer-read-only
     (set-cursor-color "grey"))
   (overwrite-mode
     (set-cursor-color "red"))
   (t
     (set-cursor-color "black"))))

(add-hook 'post-command-hook 'set-cursor-according-to-mode)
(blink-cursor-mode 1)
(setq blink-cursor-blinks 3)

;; appearance
(setq inhibit-splash-screen t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode t)
(load-theme 'tango-plus)

(set-default-font "Inconsolata-11")

;; line numbers
(defun goto-line-x (orig-goto-line)
  "display line number on interactive goto-line"
  (interactive)
  (unwind-protect
      (progn
        (linum-mode 1)
        (call-interactively orig-goto-line))
    (linum-mode -1)))

(advice-add 'goto-line :around #'goto-line-x)

;;window move
(global-set-key [(control tab)] 'other-window)

(use-package windmove
  :config (windmove-default-keybindings 'meta))

(use-package window-number
  :config (window-number-meta-mode))

;; ido
(use-package smex
  :init (ido-mode t)
  :bind (("M-x"         . smex)
         ("C-c C-c M-x" . execute-extended-command)))

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; company
(add-hook 'after-init-hook 'global-company-mode)

;; yank/kill
(use-package browse-kill-ring
  :bind (("M-y" . browse-kill-ring)))

(defun kill-ring-save-x ()
  "Copy region or line."
  (interactive)
  (apply-region-or-line #'kill-ring-save))

(defun kill-region-x ()
  "Cut region or line."
  (interactive)
  (apply-region-or-line #'kill-region))

(define-key (current-global-map) [remap kill-ring-save] 'kill-ring-save-x)
(define-key (current-global-map) [remap kill-region   ] 'kill-region-x   )

;; navigation
(defun move-beginning-of-line-x ()
  "Toggle beginning of a line and beginning of a indentation"
  (interactive)
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

(define-key (current-global-map)
  [remap move-beginning-of-line] 'move-beginning-of-line-x)

(use-package avy
  :ensure t
  :bind (("M-s" . avy-goto-word-1)))

;; editing
(delete-selection-mode 1)

;; undo
(global-undo-tree-mode)

;; global modes
(which-key-mode t)

;; compile
(setq compilation-scroll-output t)

;; suspend -> repeat
(put 'suspend-frame 'disabled t)
(global-set-key [(control z)] 'repeat)

;; scratch buffer
(defun scratch-buffer ()
  "Show or create a scratch buffer"
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))

;; dired
(use-package dired-x
  :init   (setq dired-dwim-target t)
  :config (add-hook 'dired-mode-hook 'auto-revert-mode))

;; whitespace
(setq-default indent-tabs-mode nil)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(use-package whitespace
  :init   (setq
           whitespace-style            '(trailing newline-mark newline tabs tab-mark face)
           whitespace-display-mappings '((newline-mark 10 [8629 10]))
           whitespace-global-modes     '(not erc-mode))
  :config (global-whitespace-mode))

(defun untabify-x (orig-untabify)
  "Untabify region or line"
  (interactive)
  (apply-region-or-line orig-untabify))

(advice-add 'untabify :around #'untabify-x)

;; org-mode
(use-package org
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)))

(setq org-capture-templates
      '(("b" "Bookmark" entry (file+headline "~/wrt/bookmarks.org" "bookmarks")
         "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n" :empty-lines 1)))
