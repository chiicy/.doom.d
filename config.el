;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "chiicy"
      user-mail-address "zhangchi744279297@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Cascadia Code" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-material)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-babel-temporary-directory "~/org/ts/org-babel/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; 垂直分屏
(setq split-width-threshold nil)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

(setq company-minimum-prefix-length 1)

;; lsp
(use-package! lsp-ui
  :config
  (setq 
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-show-hover t))

(use-package! lsp-mode
  :init
  ;; Let `flycheck-check-syntax-automatically' determine this.
  (setq lsp-flycheck-live-reporting t))

  (cl-defmacro lsp-org-babel-enbale (lang)
    "Support LANG in org source code block."
    (cl-check-type lang stringp)
    (let* ((edit-pre (intern (format "org-babel-edit-prep:%s" lang)))
           (intern-pre (intern (format "lsp--%s" (symbol-name edit-pre)))))
      `(progn
         (defun ,intern-pre (info)
           (let ((file-name (->> info caddr (alist-get :file))))
             (unless file-name
               (user-error "LSP:: specify `:file' property to enable"))
             (setq buffer-file-name file-name)
             (and (fboundp 'lsp)
                     ;; `lsp-auto-guess-root' MUST be non-nil.
                     (setq lsp-buffer-uri (lsp--path-to-uri file-name)
                     lsp-flycheck-live-reporting t)
                     (lsp))))
         (put ',intern-pre 'function-documentation
              (format "Enable `%s' in the buffer of org source block (%s)."
                      "lsp-mode" (upcase ,lang)))

         (if (fboundp ',edit-pre)
             (advice-add ',edit-pre :after ',intern-pre)
           (progn
             (defun ,edit-pre (info)
               (,intern-pre info))
             (put ',edit-pre 'function-documentation
                  (format "Prepare local buffer environment for org source block (%s)."
                          (upcase ,lang))))))))
(defvar org-babel-lang-list
  '("typescript" ))
(dolist (lang org-babel-lang-list)
   (eval `(lsp-org-babel-enbale ,lang)))

(after! doom-modeline
  (setq doom-modeline-github t))


(add-hook! org-mode 'auto-fill-mode)

(after! org
  (progn
    (setq org-hide-emphasis-markers t
          left-margin-width 2
          right-margin-width 2
          org-ellipsis " ▼ "
          org-pretty-entities t
          org-agenda-block-separator ""
          org-fontify-whole-heading-line t
          org-fontify-done-headline t
          org-fontify-quote-and-verse-blocks t
          org-startup-indented t
          truncate-lines nil)
    (unless (file-directory-p org-babel-temporary-directory)
      (make-directory org-babel-temporary-directory)
      )
    ))

(use-package! org-superstar ; "prettier" bullets
  :config
  (setq org-superstar-prettify-item-bullets t
        org-superstar-headline-bullets-list '("☰" "☱" "☲" "☳" "☴" "☵" "☶" "☷")))

(when IS-MAC
  (setq ns-use-thin-smoothing t)
  (add-hook 'window-setup-hook #'toggle-frame-fullscreen))

(setq fill-column 100)

;; auto save
(add-hook 'prog-mode-hook 'real-auto-save-mode)
(setq real-auto-save-interval 5)

(setq highlight-indent-guides-method 'column)
(setq highlight-indent-guides-auto-enabled nil)
(setq highlight-indent-guides-auto-odd-face-perc 15)
(setq highlight-indent-guides-auto-even-face-perc 15)
(setq highlight-indent-guides-auto-character-face-perc 20)


;; ;; auto-export
;; (defun org-mode-export-hook ()
;;   (when (equal major-mode 'org-mode)
;;     (add-hook 'after-save-hook 'org-html-export-to-html h h)
;;   )
;; )
;; (defun add-auto-export-hook() 
;;     (add-hook 'after-save-hook 'org-html-export-to-html)
;; )
;; (add-hook 'org-mode-hook  'add-auto-export-hook)


;; prettier
(add-hook 'js2-mode-hook 'prettier-js-mode)
(add-hook 'web-mode-hook 'prettier-js-mode)
(add-hook 'typescript-mode-hook 'prettier-js-mode)


(setq geiser-default-implementation 'chez)
(setq geiser-chez-bindary "scheme")

(setq geiser-repl-use-other-window nil)
(use-package ob-scheme
  :defer t
  :config
  (define-advice org-babel-scheme-get-repl (:around (old-fun &rest args) dont-switch-buffer)
    "Work-around for URL `https://github.com/jaor/geiser/issues/107'."
    (cl-letf (((symbol-function 'geiser-repl--switch-to-buffer) #'set-buffer))
      (apply old-fun args))))

(setq roam-dir "~/git/mon/org-roam/")

(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam)
  :init
  (setq org-roam-directory roam-dir)
  (setq org-roam-graph-viewer "/usr/bin/open")
  (map! :leader
        :prefix "r"
        :desc "Org-Roam-Insert" "i" #'org-roam-insert
        :desc "Org-Roam-Find" "/" #'org-roam-find-file
        :desc "Org-Roam-Buffer" "r" #'org-roam)
  :config
  (org-roam-mode +1))

(use-package deft
      :after org
      :bind
      ("C-c n d" . deft)
      :custom
      (deft-recursive t)
      (deft-use-filter-string-for-filename t)
      (deft-default-extension "org")
      (deft-directory roam-dir))

(use-package org-journal
      :bind
      ("C-c n j" . org-journal-new-entry)
      :custom
      (org-journal-dir roam-dir)
      (org-journal-date-prefix "#+TITLE: ")
      (org-journal-file-format "%Y-%m-%d.org")
      (org-journal-date-format "%A, %d %B %Y"))
    (setq org-journal-enable-agenda-integration t)
