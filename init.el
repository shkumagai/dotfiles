;;;; -*- mode: emacs-lisp; coding: utf-8-unix; indent-tabs-mode:nil -*-
;;;; refer to WDBv58 feature#2
  
;;;; Charm ;)
(require 'cl)

;;; -----------------------------------------------------------------------------
;;; Enable minor-mode only in particular major-mode
;; define a "lisp-mode-hooks"
(defun lisp-mode-hooks ()
  "lisp-mode-hooks"
  (require 'eldoc)
  (setq eldoc-idle-delay 0.2)
  (setq eldoc-echo-area-use-multiline-p t)
  (turn-on-eldoc-mode))

;; Add function to each hook variables
(add-hook 'emacs-lisp-mode-hook 'lisp-mode-hooks)
(add-hook 'lisp-interaction-mode-hook 'lisp-mode-hooks)

;;; -----------------------------------------------------------------------------
;;; Construct installation environment
;; define a "add-to-load-path"
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;; add-to-load-path both of "elisp" and "conf"
(add-to-load-path "elisp" "conf")

;;; How to load file in conf directory
;; in case of load "~/.emacs.d/conf/init-anything.el", like below.
;; (load "init-anything")

;;; -----------------------------------------------------------------------------
;;; Install "auto-install.el"
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
 (setq auto-install-directory "~/.emacs.d/elisp/")
 (auto-install-update-emacswiki-package-name t)
 ;; (setq url-proxy-services '(("http" . "localhost:8123")))
 (auto-install-compatibility-setup))

;;; -----------------------------------------------------------------------------
;;; redo+: Add redo command to Emacs :)
;; (install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")
(when (require 'redo+ nil t)
  ;; global-map
  (global-set-key (kbd "C-'") 'redo))	;asign redo function to C-'

;;; -----------------------------------------------------------------------------
;;; Add path
;; add pathes to "exec-path"
(add-to-list 'exec-path "/opt/local/bin")   ;; using MacPorts
(add-to-list 'exec-path "/opt/local/sbin")  ;; using MacPorts
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "/usr/local/sbin")
(add-to-list 'exec-path "~/bin")

;;; -----------------------------------------------------------------------------
;;; Setting language and character code
;; language: global
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

;; language: each window-system
(when (eq window-system 'ns)
  ;; MacOSX
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

(when (eq window-system 'w32)
  ;; Windows
  (setq file-name-coding-system 'sjis)
  (setq locale-coding-system 'utf-8))

(when (eq window-system 'x)
  ;; Linux, etc
  (setq file-name-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8))

;;; -----------------------------------------------------------------------------
;;; Show and emphasize information
;; show absolute path on title bar
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))
;; parentheses
(setq show-paren-delay 0)
(show-paren-mode t)
(setq show-paren-style 'parenthesis)
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "yellow")

;;; -----------------------------------------------------------------------------
;;; Use Colortheme
;; color-theme
(when window-system
  (require 'color-theme nil t)
  (color-theme-initialize)
  (color-theme-arjen)
  ;; (color-theme-gnome2)
  ;; (color-theme-goldenrod)
  )

;;; -----------------------------------------------------------------------------
;;; Change font view on faces
;; change background color in resion
(set-face-background 'region "darkgreen")
(setq frame-background-mode 'dark)

;;; -----------------------------------------------------------------------------
;;; Line highlight
;; hl-line-mode
(defface my-hl-line-face
  ;; when the background is 'dark',
  ;; :background will be 'NavyBlue'.
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; when the background is 'light',
    ;; :background will be 'LightGoldenYellow'.
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;;; -----------------------------------------------------------------------------
;;; Setting fonts
;; show available fonts list when it eval in *scratch* buffer
;; (prin1 (font-family-list))

;; font-setting Emacs23 for Mac
(when (eq window-system 'ns)
  ;; set default font
  (set-face-attribute 'default nil
		      :family "Ricty"
		      ;; 12pt
		      :height 140)
  ;; whole japanese
  ;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Hiragino_Kaku_Gothic_ProN"))
  ;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Sea_font"))
  ;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Moon_font"))
  (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Ricty"))
  ;; only 'かな' and 'カナ'
  ;; ;; U+3000-303F  CJKの記号及び句読点
  ;; ;; U+3040-309F  ひらがな
  ;; ;; U+30A0-30FF  カタカナ
  ;; (set-fontset-font nil '( #x3040 .  #x30ff) (font-spec :family "Sea_fot"))
  ;; (set-fontset-font nil '( #x3040 .  #x30ff) (font-spec :family "Moon_font"))
  ;; (set-fontset-font nil '( #x3040 .  #x30ff) (font-spec :family "Ricty"))
  ;; (set-fontset-font nil '( #x3040 .  #x30ff) (font-spec :family "NfMotoyaCedar"))

  ;; 横幅を1:2に調節
  ;;; adjust aspect ratio to 1:2
  (setq face-font-rescale-alist
	'((".*Menlo.*" . 1.0)
	  ;; (".*Hiragino_Kaku_Gothic_ProN.*" . 1.2)
	  ;; (".*Sea_font.*" . 1.2)
	  ;; (".*Moon_font.*" . 1.2)
          (".*Ricty.*" . 1.1)
	  ;; (".*nfmotoyacedar-bold.*" . 1.2)
	  ;; (".*nfmotoyacedar-medium.*" . 1.2)
	  )))

;; Windows: Consolas for Alphanumeric, Meiryo for Japanese
(when (eq window-system 'w32)
  (set-face-attribute 'default nil
		      :family "Consolas"
		      :height 110)
  (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Meiryo")))

;; Linux, etc: VL Gothic for Alphanumeric, S2G Sea font for Japanese
;; % sudo apt-get install vlgothic
(when (eq window-system 'x)
  (set-face-attribute 'default nil
		      ;; :family "Courier 10 pitch"
		      :family "Liberation Mono"
		      ;; 10.0pt
		      :height 100)
  (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Takao Gothic"))
  ;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "S2G海フォント"))
  (setq face-font-rescale-alist
	'((".*Liberation Mono.*" . 1.0)
	  ;;(".*Courier 10 pitch.*" . 1.0)
          (".*Takao Gothic.*" . 1.2)
	  ;; (".*S2G海フォント.*" . 1.2)
          )))

;;; -----------------------------------------------------------------------------
;;; Visibility
;; unable to show Start up messsage
(setq inhibit-startup-screen t)
(when window-system
  ;; tool-bar
  (tool-bar-mode 0)
  ;; scroll-bar
  (scroll-bar-mode 0))
;; blink cursor
(blink-cursor-mode t)
;; menu-bar
(menu-bar-mode 0)
;; time
(display-time)
;; column number
(column-number-mode 1)
;; default frame settings
(setq default-frame-alist
      '((width . 75)			; width(cols)  : 75
	(height . 50)			; height(lines) : 50
	(top . 10)			; top : 10px
	(left . 0)			; left : 0px
	))

;;; -----------------------------------------------------------------------------
;;; color-moccur: list-up the search results
;; (install-elisp "http://www.emacswiki.org/emacs/download/color-moccur.el")
;; (install-elisp "http://www.emacswiki.org/emacs/download/moccur-edit.el")
(when (require 'color-moccur nil t)
  ;; asign key for occur-by-moccur as global
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; AND condition search using splited with space
  (setq moccur-split-word t)
  ;; exclude file names when search directory
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (require 'moccur-edit nil t)
  ;; use migemo if it is available
  (when (and (executable-find "cmigemo")
	     (require 'migemo nil t))
    (setq moccur-use-migemo t)))

;;; -----------------------------------------------------------------------------
;;; grep-edit: direct edit on grep resutls
;; (install-elisp "http://www.emacswiki.org/emacs/download/grep-edit.el")
(require 'grep-edit)

;;; -----------------------------------------------------------------------------
;;; migemo: incremental search of Roman script
;; sudo apt-get install migemo
;; (install-elisp-from-gist "http://gist.github.com/457761")
(when (and (executable-find "cmigemo")
	   (require 'migemo nil t))
  ;; use cmigemo
  (setq migemo-command "cmigemo")
  ;; command line options
  (setq migemo-options '("-q" "--emacs" "-i" "\a"))
  ;; path to dictionary
  (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
  ;; cmigemoで必須の設定
  ;; required setting in cmigemo
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  ;; cache setting
  (setq migemo-use-pattern-alist t)
  (setq migemo-use-frequent-pattern-alist t)
  (setq migemo-pattern-alist-length 1000)
  (setq migemo-coding-system 'utf-8-unix)
  ;; initialize migemo
  (migemo-init))

;;; -----------------------------------------------------------------------------
;;; undohist: enable undo on closed buffer
;; (install-elisp "http://cx4a.org/pub/undohist.el")
(when (require 'undohist nil t)
  (undohist-initialize))

;;; -----------------------------------------------------------------------------
;;; undo-tree: visualize undo branches
;; ;; (install-elisp "http://www.dr-qubit.org/undo-tree/undo-tree.el")
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))

;;; -----------------------------------------------------------------------------
;;; point-undo: undo a cursor position
;; ;; (install-elisp "http://www.emacswiki.org/cgi-bin/wiki/download/point-undo.el")
(when (require 'point-undo nil t)
  (define-key global-map (kbd "M-[") 'point-undo)
  (define-key global-map (kbd "M-]") 'point-redo))

;;; -----------------------------------------------------------------------------
;;; wdired: enable file name edit directly in wdired
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;;; -----------------------------------------------------------------------------
;;; auto-complete-mode: 高機能補完+ポップアップメニュー
;;; auto-complete-mode: high performance completion and popup menu
;; wget http://cx4a.org/pub/auto-complete/auto-complete-1.3.tar.bz2
;; tar bxf auto-complete-1.3.tar.bz2
;; (load-file "~/path/to/auto-complete-1.3")
;; (when (require 'auto-complete-config nil t)
;;   (add-to-list 'ac-dictionary-directories "~/.emacs.d/elisp/ac-dict")
;;   (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
;;   (ac-config-default))

;;; -----------------------------------------------------------------------------
;;; smartchr: cycle snippet
;; (install-elisp "https://github.com/imakado/emacs-smartchr/raw/master/smartchr.el")
(when (require 'smartchr nil t)
  (defun cperl-mode-hooks ()
    (define-key cperl-mode-map (kbd "=") (smartchr '("=" " = " " == " " => "))))
  (add-hook 'cperl-mode-hook 'cperl-mode-hooks)
  (defun css-mode-hooks ()
    (define-key cssm-mode-map (kbd ":") (smartchr '(": " ":"))))
  (add-hook 'css-mode-hook 'css-mode-hooks))

;;; -----------------------------------------------------------------------------
;;; ELscreen: enable window management like GNU Screen
(when (require 'elscreen nil t)
  (if window-system
      (define-key elscreen-mode-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-mode-map (kbd "C-z") 'suspend-emacs)))

;;; -----------------------------------------------------------------------------
;;; anything
;; (auto-install-batch "anything")
(require 'anything-startup)

;;; -----------------------------------------------------------------------------
;;; sdic + 英辞郎 第五版
;;; http://d.hatena.ne.jp/zqwell-ss/20091205/1260037903
;;; http://d.hatena.ne.jp/eiel/20090111#1231681381
;;; http://nox-insomniae.ddo.jp/insomnia/2009/01/eijiro-emacs.html
;;; http://d.hatena.ne.jp/kyagi/20090515/1242379726

(autoload 'sdic-describe-word "sdic" "英単語の意味を調べる" t nil)
(global-set-key (kbd "C-c w") 'sdic-describe-word)
(autoload 'sdic-describe-word-at-point "sdic" "カーソル位置の英単語の意味を調べる" t nil)
(global-set-key (kbd "C-c W") 'sdic-describe-word-at-point)

(setq sdic-eiwa-dictionary-list
      '((sdicf-client "~/work/dictionaries/eijiro118.sdic")))
(setq sdic-waei-dictionary-list
      '((sdicf-client "~/work/dictionaries/waeiji118.sdic"
		      (add-keys-to-headword t))))
(setq sdic-default-coding-system 'utf-8-unix)

;;; -----------------------------------------------------------------------------
;;; cperl-mode
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist
      (cons '("\\.t$" . cperl-mode) auto-mode-alist))
(setq cperl-auto-newline nil)
(setq cperl-indent-parens-as-block t)
(setq cperl-close-paren-offset -4)
(setq cperl-indent-level 4)
(setq cperl-level-offset -4)
(setq cperl-continuted-statement-offset 4)
(setq cperl-highlight-variables-indiscriminaly t)
(add-hook 'cperl-mode-hook
	  (lambda ()
	    (set-face-italic-p 'cperl-hash-face nil)))
(add-hook 'cperl-mode-hook
	  '(lambda ()
	     (define-key cperl-mode-map (kbd "C-c c") 'cperl-check-syntax)
	     (setq indent-tabs-mode nil)))

;;; -----------------------------------------------------------------------------
;;; perltidy
;;; % cpan -i Perl::Tidy
;; (defmacro mark-active ()
;;   "xemacs/emacs compatibility macro"
;;   (if (boundp 'mark-active)
;;       'mark-active
;;     '(mark)))

;; (defun perltidy ()
;;   "Run perltidy on the current region or buffer."
;;   (interactive)
;;   ;; Inexplicably, save-excursion doesn't work here.
;;   (let ((orig-point (point)))
;;     (unless (mark-active) (mark-defun))
;;     (shell-command-on-region (point) (mark) "perltidy -q" nil t)
;;     (goto-char orig-point)))

;; (global-set-key (kbd "C-c t") 'perltidy)

;; (defvar pertidy-mode nil
;;   "Automatically 'perltidy' when saving.")
;; (make-variable-buffer-local 'perltidy-mode)
;; (defun perltidy-write-hook ()
;;   "Perltidys a buffer during 'write-file-hools' for 'perltidy-mode'"
;;   (if perltidy-mode
;;       (save-excursion
;; 	(widen)
;; 	(mark-whole-buffer)
;; 	(not (perltidy)))
;;     nil))
;; (defun perltidy-mode (&optional arg)
;;   "Perltidy minor mode."
;;   (interactive "P")
;;   (setq perltidy-mode
;; 	(if (null arg)
;; 	    (not perltidy-mode)
;; 	  (> (prefix-numeric-value-arg) 0)))
;;   (mark-local-hook 'write-file-hooks)
;;   (if perltidy-mode
;;       (add-hook 'write-file-hooks 'perktidy-write-hook)
;;     (remove-hook 'write-file-hooks 'perltidy-write-hook)))
;; (if (not (assq 'perltidy-mode minor-mode-alist))
;;     (setq minor-mode-alist
;; 	  (cons '(perltidy-mode " Perltidy")
;; 		minor-mode-alist)))
;; (eval-after-load "cperl-mode"
;;   '(add-hook 'cperl-mode-hook 'perltidy-mode))


;;; -----------------------------------------------------------------------------
;;; python-mode
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode)
				   interpreter-mode-alist))

;;; -----------------------------------------------------------------------------
;;; rst-mode
;; (install-elisp "http://docutils.sourceforge.org/tools/editors/emacs/rest.el")
(when (require 'rst nil t)
  ;; target file extensions
  (setq auto-mode-alist
	(cons '("\\.re?st$" . rst-mode) auto-mode-alist))
  ;; ;; slide open with Firefox
  ;; (add-hook 'rst-mode-hook
  ;;           (lambda ()
  ;;             (setq rst-slides-program "open -a Firefox")))
  ;; add-hook for indentation with spaces
  (add-hook 'rst-mode-hook '(labmda() (setq indent-tabs-mode nil)))
  )

;;; -----------------------------------------------------------------------------
;;; hg-mode
(push "/opt/local/share/mercurial/contrib" load-path)
(load-library "mercurial")
(load-library "mq")        ;; MQ(Mercurial Queue) で patch を管理する場合


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((syntax . elisp)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;;;; -*- end of init.el -*-
