;; Device Registration Contract
;; Stores medical equipment details and provides functions to register and retrieve equipment information

;; Define data variables
(define-data-var admin principal tx-sender)

;; Define data maps
(define-map devices
  { device-id: (string-ascii 32) }
  {
    type: (string-ascii 64),
    model: (string-ascii 64),
    manufacturer: (string-ascii 64),
    purchase-date: uint,
    owner: principal,
    status: (string-ascii 16)
  }
)

;; Define public functions
(define-public (register-device
                (device-id (string-ascii 32))
                (type (string-ascii 64))
                (model (string-ascii 64))
                (manufacturer (string-ascii 64))
                (purchase-date uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? devices { device-id: device-id })) (err u100))
    (ok (map-set devices
      { device-id: device-id }
      {
        type: type,
        model: model,
        manufacturer: manufacturer,
        purchase-date: purchase-date,
        owner: tx-sender,
        status: "active"
      }
    ))
  )
)

(define-public (update-device-status
                (device-id (string-ascii 32))
                (new-status (string-ascii 16)))
  (let ((device (unwrap! (map-get? devices { device-id: device-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set devices
      { device-id: device-id }
      (merge device { status: new-status })
    ))
  )
)

(define-public (transfer-device-ownership
                (device-id (string-ascii 32))
                (new-owner principal))
  (let ((device (unwrap! (map-get? devices { device-id: device-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set devices
      { device-id: device-id }
      (merge device { owner: new-owner })
    ))
  )
)

;; Define read-only functions
(define-read-only (get-device-details (device-id (string-ascii 32)))
  (map-get? devices { device-id: device-id })
)

;; Define admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
