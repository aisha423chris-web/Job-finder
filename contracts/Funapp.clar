;; Funapp.clar
;; Simple liquidity pool  deposit STX  receive LP tokens
;; Uses a separate SIP-010 LP token contract

(define-trait lp-token-trait
  (
    ;; Mint LP tokens to a recipient: (amount uint) (recipient principal) -> (response bool uint)
    (mint (uint principal) (response bool uint))
    ;; Burn LP tokens from an owner: (amount uint) (owner principal) -> (response bool uint)
    (burn (uint principal) (response bool uint))
    ;; Get total supply -> (response uint uint)
    (get-total-supply () (response uint uint))
    ;; Get balance of a principal -> (response uint uint)
    (get-balance (principal) (response uint uint))
  )
)

(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u101))
(define-constant ERR-INSUFFICIENT-LP (err u102))
(define-constant ERR-UNAUTHORIZED (err u103))

(define-data-var owner principal tx-sender)
(define-data-var total-liquidity uint u0)

;; LP token contract (deployed separately - replace with real address)
(define-constant lp-token-contract .lp-token)

;; Map: user  deposited STX (used only for UI convenience)
(define-map user-deposits principal uint)

;; --------------------------------------------------------------------
;; Public functions
;; --------------------------------------------------------------------
(define-public (deposit-liquidity (amount uint) (lp-token <lp-token-trait>))
  (let
    ((caller tx-sender))
    (asserts! (> amount u0) ERR-INSUFFICIENT-LIQUIDITY)

    ;; 1. Transfer STX to this contract
    (try! (stx-transfer? amount caller (as-contract tx-sender)))

    ;; 2. Mint LP tokens (1 STX = 1_000_000 LP)
    (let
      ((lp-to-mint (* amount u1000000))
       (new-total (+ (var-get total-liquidity) amount)))
      (var-set total-liquidity new-total)

      ;; Update user deposit tracking
      (map-set user-deposits caller
        (+ (default-to u0 (map-get? user-deposits caller)) amount))

      ;; Mint LP tokens to caller
      (try! (contract-call? lp-token mint lp-to-mint caller))

      (print {event: "deposit", user: caller, stx: amount, lp: lp-to-mint})
      (ok lp-to-mint)
    )
  )
)

(define-public (withdraw-liquidity (lp-amount uint) (lp-token <lp-token-trait>))
  (let
    ((caller tx-sender)
     (total-lp (try! (contract-call? lp-token get-total-supply)))
     (total-stx (var-get total-liquidity)))
    (asserts! (> lp-amount u0) ERR-INSUFFICIENT-LIQUIDITY)
    (asserts! (> total-lp u0) ERR-INSUFFICIENT-LP)

    ;; Compute proportional STX to return
    (let
      ((stx-to-return (/ (* lp-amount total-stx) total-lp))
       (new-total (- total-stx stx-to-return)))

      ;; Burn LP tokens
      (try! (contract-call? lp-token burn lp-amount caller))

      ;; Update state
      (var-set total-liquidity new-total)
      (map-set user-deposits caller
        (- (default-to u0 (map-get? user-deposits caller)) stx-to-return))

      ;; Send STX back
      (as-contract (try! (stx-transfer? stx-to-return tx-sender caller)))

      (print {event: "withdraw", user: caller, lp-burned: lp-amount, stx-returned: stx-to-return})
      (ok stx-to-return)
    )
  )
)

;; --------------------------------------------------------------------
;; Read-only helpers
;; --------------------------------------------------------------------
(define-read-only (get-total-liquidity)
  (var-get total-liquidity)
)

(define-read-only (get-user-deposit (user principal))
  (default-to u0 (map-get? user-deposits user))
)

(define-public (get-lp-balance (user principal) (lp-token <lp-token-trait>))
  (contract-call? lp-token get-balance user)
)

;; --------------------------------------------------------------------
;; Owner only
;; --------------------------------------------------------------------
(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
    (var-set owner new-owner)
    (ok true)
  )
)