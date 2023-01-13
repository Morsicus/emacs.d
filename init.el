;; Remove startup message
(setq inhibit-startup-message t)

(scroll-bar-mode -1) ;; Disable scroll bar
(tool-bar-mode -1)   ;; Disable the tool bar
(tooltip-mode -1)    ;; Disable tooltip
(set-fringe-mode 10) ;; Give some breathing room
(menu-bar-mode -1)   ;; Disable menu bar

;; Fullscreen at startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Enable line number
(column-number-mode)
(global-display-line-numbers-mode t)

;; Save backup files into a specific directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))

;; Ease the process to move across windows
;; Use <shift+Arrow>
(windmove-default-keybindings)

(dolist (mode '(org-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Make escape quit prompt
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize packages
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1)
  (setq ivy-use-selectable-prompt t))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

;; NOTE: The first time that this configuration is loaded
;; You'll need to run those commands manually:
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

;; Enable cool icons in dired
(use-package all-the-icons-dired
  :ensure t
  :hook
  (dired-mode . all-the-icons-dired-mode)
  )

;; Enable cool icons in ivy
(use-package all-the-icons-ivy
  :ensure t
  :init
  (all-the-icons-ivy-setup))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-palenight t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Prettier Mode line
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 5)
  "scale text"
  ("+" text-scale-increase "in")
  ("-" text-scale-decrease "out")
  ("k" nil "finished" :exit t))

(use-package general
  :config
  (general-create-definer morsicus/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (morsicus/leader-keys
    "a"  '(:ignore t :which-key "apps")
    "ag" '(magit-status :which-key "git")
    
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(ibuffer :which-key "list")
    "bd" '(kill-buffer :which-key "kill")
    "bD" '(kill-other-buffers :which-key "kill-others")
    "bn" '(next-buffer :which-key "next")
    "bp" '(previous-buffer :which-key "previous")

    "f"  '(:ignore t :which-key "files")
    "ff" '(counsel-find-file :which-key "find")

    "l"  '(:ignore t :which-key "lsp")
    
    "g"  '(:ignore t :which-key "go")
    "gd" '(lsp-find-definition :which-key "definition")
    "gr" '(lsp-ui-peek-find-references :which-key "references")

    "o"  '(:ignore t :which-key "org")
    "oa"  '(org-roam-alias-add :which-key "roam-alias")
    "ol"  '(org-roam-buffer-toggle :which-key "roam-list")
    "of"  '(org-roam-node-find :which-key "roam-find")
    "oi"  '(org-roam-node-insert :which-key "roam-insert")
    
    "s"  '(swiper-isearch :which-key "search")

    "x"  '(counsel-M-x :which-key "exec")
    "z"  '(hydra-text-scale/body :which-key "zoom")))

;; Magit
(use-package magit)

;; Buffers
(defun kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer 
          (delq (current-buffer) 
                (remove-if-not 'buffer-file-name (buffer-list)))))

;; LSP
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((python-mode go-mode) . lsp-deferred)
  :demand t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-auto-configure t)
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :config
  (setq lsp-ui-flycheck-enable t)
  (add-to-list 'lsp-ui-doc-frame-parameters '(no-accept-focus . t))
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-ivy)

;; Autocompletion
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; Java
(use-package lsp-java
  :config (add-hook 'java-mode-hook 'lsp))

(use-package go-mode
  :config (add-hook 'go-mode-hook 'lsp-deferred))

(use-package terraform-mode
  :config (add-hook 'terraform-mode-hook 'lsp-deferred))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/Documents/Org/Roam")
  :config
  (org-roam-setup))
