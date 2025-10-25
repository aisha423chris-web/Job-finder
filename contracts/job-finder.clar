;; jobfinder-app
;; Clarity contract for a decentralized job marketplace

(define-data-var job-counter uint u0)

(define-map jobs {id: uint}
  {employer: principal,
   title: (string-ascii 50),
   applicant: (optional principal),
   status: (string-ascii 10)})

;; Post a job
(define-public (post-job (title (string-ascii 50)))
  (begin
    (asserts! (> (len title) u0) (err u1))
    (let
      (
        (id (var-get job-counter))
      )
      (map-set jobs {id: id}
        {employer: tx-sender,
         title: title,
         applicant: none,
         status: "open"})
      (var-set job-counter (+ id u1))
      (ok id)
    )
  )
)

;; Apply for a job
(define-public (apply-job (id uint))
  (match (map-get? jobs {id: id})
    job
    (if (is-eq (get status job) "open")
      (begin
        (map-set jobs {id: id}
          {employer: (get employer job),
           title: (get title job),
           applicant: (some tx-sender),
           status: "applied"})
        (ok "Job applied")
      )
      (err u2)) ;; not open
    (err u3)) ;; job not found
)

;; Hire an applicant
(define-public (hire-applicant (id uint))
  (match (map-get? jobs {id: id})
    job
    (if (and (is-eq (get status job) "applied") (is-eq tx-sender (get employer job)))
      (begin
        (map-set jobs {id: id}
          {employer: (get employer job),
           title: (get title job),
           applicant: (get applicant job),
           status: "hired"})
        (ok "Applicant hired")
      )
      (err u4)) ;; not applied or not employer
    (err u5)) ;; job not found
)