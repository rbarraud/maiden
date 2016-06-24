#|
 This file is a part of Maiden
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.maiden.agents.crimes)

(defvar *cardcast/decks* "https://api.cardcastgame.com/v1/decks")
(defvar *cardcast/deck* "https://api.cardcastgame.com/v1/decks/~a")
(defvar *cardcast/dec/cards* "https://api.cardcastgame.com/v1/decks/~a/cards")

(defun cardcast/decks (&key (offset 0) (limit 20) search author category)
  (request-as :json *cardcast/decks* :get `((offset ,offset)
                                            (limit ,limit)
                                            ,@(append
                                               (when search `((search ,search)))
                                               (when author `((author ,author)))
                                               (when category `((category ,category)))))))

(defun cardcast/deck (deck-id)
  (request-as :json (format NIL *cardcast/deck* deck-id)))

(defun cardcast/deck/cards (deck-id)
  (request-as :json (format NIL *cardcast/deck/cards* deck-id)))

(defun cardcast->card (type data)
  (make-instance type :id (json-v data :id)
                      :text (case type
                              (response (first (json-v data :text)))
                              (T (json-v data :text)))))

(defun load-cardcast-deck (deck-id)
  (let ((deckinfo (cardcast/deck deck-id)))
    (when (string-equal "not_found" (json-v deckinfo :id))
      (error "No deck with ID ~a found." deck-id))
    (let ((cards (cardcast/deck/cards deck-id)))
      (make-instance 'deck :name (json-v deckinfo :name)
                           :calls (loop for data in (json-v cards :calls)
                                        collect (cardcast->card 'call data))
                           :responses (loop for data in (json-v cards :responses)
                                            collect (cardcast->card 'response data))))))

(defun find-cardcast-decks (query)
  (let ((data (cardcast/decks :search query)))
    (loop for dat in (json-v data :results :data)
          collect (list (json-v dat :name) (json-v dat :code)))))
