(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-expired (err u104))
(define-constant err-revoked (err u105))

(define-data-var next-credential-id uint u1)

(define-map credentials
    { credential-id: uint }
    {
        recipient: principal,
        issuer: principal,
        credential-type: (string-ascii 50),
        credential-name: (string-ascii 100),
        issue-date: uint,
        expiry-date: uint,
        metadata-uri: (string-utf8 256),
        revoked: bool,
    }
)

(define-map issuers
    { issuer: principal }
    {
        name: (string-ascii 100),
        website: (string-utf8 256),
        verified: bool,
        active: bool,
    }
)

(define-map issuer-credentials
    {
        issuer: principal,
        credential-id: uint,
    }
    { active: bool }
)

(define-map recipient-credentials
    {
        recipient: principal,
        credential-id: uint,
    }
    { active: bool }
)

(define-map authorized-verifiers
    { verifier: principal }
    { active: bool }
)

(define-read-only (get-credential (credential-id uint))
    (match (map-get? credentials { credential-id: credential-id })
        credential (ok credential)
        (err u404)
    )
)

(define-read-only (get-issuer (issuer principal))
    (match (map-get? issuers { issuer: issuer })
        issuer-data (ok issuer-data)
        (err u404)
    )
)

(define-read-only (is-authorized-verifier (verifier principal))
    (match (map-get? authorized-verifiers { verifier: verifier })
        verifier-data (ok verifier-data)
        (err u404)
    )
)

(define-read-only (get-recipient-credentials (recipient principal))
    (ok (map-get? recipient-credentials {
        recipient: recipient,
        credential-id: u0,
    }))
)

(define-read-only (get-issuer-credentials (issuer principal))
    (ok (map-get? issuer-credentials {
        issuer: issuer,
        credential-id: u0,
    }))
)

(define-read-only (verify-credential
        (credential-id uint)
        (recipient principal)
    )
    (match (map-get? credentials { credential-id: credential-id })
        credential (begin
            (if (not (is-eq (get recipient credential) recipient))
                (err u401)
                (if (get revoked credential)
                    (err u403)
                    (if (> (get expiry-date credential) stacks-block-height)
                        (ok true)
                        (err u410)
                    )
                )
            )
        )
        (err u404)
    )
)

(define-public (register-issuer
        (name (string-ascii 100))
        (website (string-utf8 256))
    )
    (let ((issuer tx-sender))
        (match (map-get? issuers { issuer: issuer })
            issuer-data (err u409)
            (begin
                (map-set issuers { issuer: issuer } {
                    name: name,
                    website: website,
                    verified: false,
                    active: true,
                })
                (ok true)
            )
        )
    )
)

(define-public (verify-issuer (issuer principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (match (map-get? issuers { issuer: issuer })
            issuer-data (begin
                (map-set issuers { issuer: issuer }
                    (merge issuer-data { verified: true })
                )
                (ok true)
            )
            (err u404)
        )
    )
)

(define-public (add-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-verifiers { verifier: verifier } { active: true })
        (ok true)
    )
)

(define-public (remove-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-verifiers { verifier: verifier })
        (ok true)
    )
)

(define-public (issue-credential
        (recipient principal)
        (credential-type (string-ascii 50))
        (credential-name (string-ascii 100))
        (expiry-date uint)
        (metadata-uri (string-utf8 256))
    )
    (let (
            (issuer tx-sender)
            (credential-id (var-get next-credential-id))
        )
        (match (map-get? issuers { issuer: issuer })
            issuer-data (begin
                (asserts! (get active issuer-data) err-unauthorized)
                (map-set credentials { credential-id: credential-id } {
                    recipient: recipient,
                    issuer: issuer,
                    credential-type: credential-type,
                    credential-name: credential-name,
                    issue-date: stacks-block-height,
                    expiry-date: expiry-date,
                    metadata-uri: metadata-uri,
                    revoked: false,
                })
                (map-set issuer-credentials {
                    issuer: issuer,
                    credential-id: credential-id,
                } { active: true }
                )
                (map-set recipient-credentials {
                    recipient: recipient,
                    credential-id: credential-id,
                } { active: true }
                )
                (var-set next-credential-id (+ credential-id u1))
                (ok credential-id)
            )
            (err u404)
        )
    )
)
(define-public (revoke-credential (credential-id uint))
    (match (map-get? credentials { credential-id: credential-id })
        credential (begin
            (asserts! (is-eq (get issuer credential) tx-sender) err-unauthorized)
            (map-set credentials { credential-id: credential-id }
                (merge credential { revoked: true })
            )
            (ok true)
        )
        (err u404)
    )
)
