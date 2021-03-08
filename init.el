;; Repos
(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Ensure we have use-package installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Automatically install missing packages
(require 'use-package)
(setq use-package-always-ensure t)

;; Global settings
(setq-default delete-selection-mode t)
(setq-default indent-tabs-mode nil)
(setq-default fill-column 80)
(global-set-key (kbd "C-c C-e") 'eval-buffer)

;; Nyanyanya
(use-package nyan-mode
  :config
  (nyan-mode t)
  (nyan-start-animation)
  (nyan-toggle-wavy-trail)
  (setq-default nyan-bar-length 24)
  (setq-default nyan-minimum-window-width 80))

;; Licence
(use-package lice
  :config
  (setq-default lice:default-license "gpl-3.0"
                lice:copyright-holder "Joakim Skogø Langvand"))

;; Remove menubar, toolbar, scrollbars
(unless (eq window-system 'ns)
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

;; Modeline
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))
(use-package all-the-icons)
(setq doom-modeline-buffer-file-name-style 'file-name)
(use-package ghub
  :config
  (setq doom-modeline-github t))
(setq auth-sources '("~/.authinfo"))

;; Theme
;(use-package material-theme
;  :config
;  (load-theme 'material t))
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; FCI
(add-hook 'prog-mode-hook
	  (lambda()
            (message "Custom programming mode hook")
	    (linum-mode t)))

;; Company
(use-package company
  :config
  (global-company-mode t)
  (setq-default company-minimum-prefix-length 1
                company-idle-delay 0)
  :bind
  ("C-M-n" . company-select-next-or-abort)
  ("C-M-p" . company-select-previous-or-abort))

;; Highlight matching parentheses
(setq-default show-paren-mode t)

;; Which-key
(use-package which-key
  :config
  (which-key-mode))

;; Yasnippet
(use-package yasnippet
  :config
  (yas-global-mode))
(use-package yasnippet-snippets)

;; Indium
;(use-package indium)

;; LSP
(use-package lsp-mode
  :init
  (setq lsp-prefer-flymake nil)
  :bind
  ("C-c C-r" . lsp-rename)
  :hook
  ((lsp-mode . lsp-enable-which-key-integration)
   (java-mode)
   (java-mode . lsp)))
  ;;:config
  ;;(setq lsp-completion-enable-additional-text-edit nil))
(use-package lsp-ui
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-sideline-enable t
        lsp-ui-flycheck-enable t))

;; Helm
(use-package helm
  :config
  (helm-mode))
(use-package helm-lsp)

;; Git
(use-package magit)

;; Project management
(use-package projectile)
(use-package treemacs
  :bind
  (([(XF86Tools)] . treemacs)
   ("C-<XF86Tools>" . treemacs-switch-workspace)
   ("C-c t" . treemacs-switch-workspace)))
(use-package lsp-treemacs)

;; Flycheck
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))

;; Emacs Lisp
(defun er-byte-compile-init-dir ()
  "Byte-compile dotfiles."
  (interactive)
  (byte-recompile-directory user-emacs-directory 0))
(defun er-remove-elc-on-save ()
  "Remove byte-compiled file on save."
  (add-hook 'after-save-hook
            (lambda ()
              (if (file-exists-p (concat buffer-file-name "c"))
                  (delete-file (concat buffer-file-name "c"))))
            nil
            t))
(add-hook 'emacs-lisp-mode-hook 'er-remove-elc-on-save)

;; Java
(defun my-java-mode-hook ()
  (message "Custom Java mode hook")
  (auto-fill-mode)
  (flycheck-mode)
  ;(git-gutter-mode)
  ;(gtags-mode)
  (subword-mode)
  (yas-minor-mode)
  (set-fringe-style '(8 . 0))
  (define-key c-mode-base-map (kbd "C-M-j") 'tkj-insert-serial-version-uuid)
  (define-key c-mode-base-map (kbd "C-m") 'c-context-line-break)
  (define-key c-mode-base-map (kbd "S-<f7>") 'gtags-find-tag-from-here)
  (lsp) ; Why doesn't this work?
  ;; Fix indentation for anonymous classes
  (c-set-offset 'substatement-open 0)
  (if (assoc 'inexpr-class c-offsets-alist)
      (c-set-offset 'inexpr-class 0)
    ;; Indent arguments on the next line as indented body.
    (c-set-offset 'arglist-intro '++)))
(add-hook 'java-mode-hook 'my-java-mode-hook)
(use-package lsp-java
  :demand t)
(use-package flycheck
  :init
  (add-to-list 'display-buffer-alist
               `(,(rx bos "*Flycheck errors*" eos)
                 (display-buffer-reuse-window
                  display-buffer-in-side-window)
                 (side            . bottom)
                 (reusable-frames . visible)
                 (window-height   . 0.15))))
(defun tkj-projectile-grep-region()
  "Search the project for the text in region"
  (interactive)
  (projectile-grep (buffer-substring (mark) (point))))
(use-package projectile :ensure t)
(use-package yasnippet :ensure t)
(use-package lsp-mode :ensure t
  :bind
  (:map lsp-mode-map
        (("\C-\M-b" . lsp-find-implementation)
         ("M-RET" . lsp-execute-code-action)))
  :config
  (setq lsp-inhibit-message t
        lsp-eldoc-render-all nil
        lsp-enable-file-watchers nil
        ;lsp-enable-symbol-highlighting nil
        lsp-headerline-breadcrumb-enable nil
        ;lsp-highlight-symbol-at-point nil
        lsp-modeline-code-actions-enable nil
        lsp-modeline-diagnostics-enable nil
        )
  ;; Performance tweaks, see
  ;; https://github.com/emacs-lsp/lsp-mode#performance
  (setq gc-cons-threshold 100000000
        read-process-output-max (* 1024 1024) ;; 1mb
        lsp-idle-delay 0.500))
(use-package hydra :ensure t)
(use-package company-lsp :ensure t)
(use-package lsp-ui
  :ensure t
  :config
  (setq lsp-prefer-flymake nil
        lsp-ui-doc-delay 5.0
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-symbol nil))
(use-package lsp-java
  :ensure t)
(use-package dap-mode
  :after
  lsp-mode
  :config
  (dap-auto-configure-mode))
(use-package dap-java
  :ensure nil)

;; Gradle
(use-package gradle-mode)

;; Groovy
(use-package groovy-mode)

;; Python
(use-package elpy)
;(use-package jedi
;  :config
;  (setq-default jedi:complete-on-dot t))
(use-package company-jedi
  :ensure t
  :config
  (add-to-list 'company-backends 'company-jedi)
  :bind
  ("C-c j" . company-jedi)
  :hook
  (python-mode))
(use-package pyvenv
  :ensure t
  :hook
  ((python-mode . pyvenv-mode)))

;; LaTeX
(use-package lsp-latex)

;; C++
(use-package modern-cpp-font-lock
  :ensure t)
(use-package cmake-ide
  :config
  (cmake-ide-setup)
  :hook
  (c++-mode))
(defun my-c++-mode-hook ()
  (message "Custom c++ mode hook")
  (require 'lsp-clients)
  (lsp-clients-register-clangd)
  (lsp))
(setq company-clang-arguments '("-std=c++17"))
(add-hook 'c++-mode-hook 'my-c++-mode-hook)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-fill-column-indicator-mode t)
 '(debug-on-error t)
 '(delete-selection-mode t)
 '(doom-modeline-mode t)
 '(gradle-mode t)
 '(helm-completion-style 'emacs)
 '(package-selected-packages
   '(groovy-mode gradle-mode cmake-ide modern-cpp-font-lock yasnippet-snippets lice auto-fill-mode pyenv-mode ghub doom-themes doom-one-theme doom-one doom-modeline which-key use-package projectile nyan-mode material-theme magit lsp-ui lsp-latex lsp-java helm-lsp flycheck elpy company-lsp company-jedi))
 '(pyvenv-mode t)
 '(show-paren-mode t)
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
