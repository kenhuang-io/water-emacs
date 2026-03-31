(use-package pdf-tools
  ;; :ensure t
  :pin manual ; don't reinstall when package updates
  :mode  ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :config
  ;; (setq-default pdf-view-display-size 'fit-page)
  ;; ;; automatically annotate highlights
  ;; (setq pdf-annot-activate-created-annotations t)
  (pdf-tools-install 'no-query)
  (add-hook 'pdf-view-mode-hook #'pdf-view-themed-minor-mode)
  ;; use normal isearch as swiper doesn't work here
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (require 'pdf-occur))

;; part of pdf-tools
(use-package pdf-view
  :after (pdf-tools)
    :bind (:map pdf-view-mode-map
                ([remap scroll-up-command] . #'pdf-view-scroll-up-or-next-page)
                ([remap scroll-down-command] . #'pdf-view-scroll-down-or-previous-page)))

(use-package nov
  :ensure t
  :mode ("\\.epub\\'" . nov-mode)
  :bind (:map nov-mode-map
              ([remap scroll-up-command] . #'nov-scroll-up)
              ([remap scroll-down-command] . #'nov-scroll-down)))

(use-package org-noter
  :init (setq               ; org-noter-default-notes-file-names "xxx"
         org-noter-arrow-horizontal-offset 300
         org-noter-arrow-background-color "black"
         org-noter-notes-search-path (list w/pdf-outline-export-dir)
         org-noter-doc-split-fraction '(0.6 . 0.5))
  :ensure t)

(use-package w3m
  :init
  (setq w3m-use-favicon nil))

(defun w/org-noter-kill-session@before (&rest _)
  "Sync back the point position."
  (when (and org-noter--session
             org-noter-use-indirect-buffer
             (org-noter--session-notes-buffer org-noter--session))
    (let* ((notes-buffer (org-noter--session-notes-buffer org-noter--session))
           (base-buffer (buffer-base-buffer notes-buffer))
           (window (get-buffer-window base-buffer))
           (frame (window-frame window))
           (cur-frame (selected-frame))
           point)
      (with-current-buffer notes-buffer
        (setq point (point)))
      ;; with-current-buffer doesn't move point in this senario
      ;; doesn't work either
      ;; (switch-to-buffer base-buffer)
      ;; (goto-char point)
      ;; (switch-to-buffer notes-buffer)

      ;; doesn't work due to window not live TODO how to with selected tab-bar???
      (raise-frame frame)
      ;; (sleep-for 1)
      ;; (with-selected-frame frame)
      (message "xxx selected frame")
      (when (window-live-p window)
        (message "xxx window live!")
        (with-current-buffer base-buffer
          (goto-char point)))
      (raise-frame cur-frame)
      ;; (sleep-for 1)
      )))

(advice-add #'org-noter-kill-session :before #'w/org-noter-kill-session@before)
