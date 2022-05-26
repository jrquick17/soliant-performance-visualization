SELECT invoiceStatement.invoiceStatementID
     , invoiceStatement.previousBalance
     , invoiceStatement.dateAdded
     , invoiceStatement.dateLastModified
     , invoiceStatement.billingPeriodEndDate
     , invoiceStatement.clientCorporationID
     , invoiceStatement.purchaseOrderNumber
     , invoiceStatement.paymentTerms
     , invoiceStatement.dueDate
     , invoiceStatement.currencyUnitID
     , invoiceStatement.billingProfileID
     , invoiceStatement.remitInstructions
     , invoiceStatement.invoiceStatementDate
     , invoiceStatement.taxAmount
     , invoiceStatement.discountAmount
     , invoiceStatement.surchargeAmount
     , invoiceStatement.userID
     , invoiceStatement.billingClientContactUserID
     , invoiceStatement.billingAttention
     , invoiceStatement.billingAddress1
     , invoiceStatement.billingAddress2
     , invoiceStatement.billingCity
     , invoiceStatement.billingState
     , invoiceStatement.billingZip
     , invoiceStatement.billingCountryID
     , invoiceStatement.invoiceStatementNumber
     , invoiceStatement.invoiceStatementTypeLookupID
     , invoiceStatement.invoiceStatementOrigin
     , invoiceStatement.invoiceTermID
     , invoiceStatement.billingScheduleID
     , invoiceStatement.billingCorporateUserID
     , invoiceStatement.deliveryMethod
     , invoiceStatement.deliveryMethodLookupID
     , invoiceStatement.isFinalized
     , invoiceStatement.emailErrorReason
     , invoiceStatement.invoiceStatementFinalizedDate
     , invoiceStatement.invoiceStatementDistributionBatchID
     , invoiceStatement.rebillNumberFromInvoiceStatementID
     , invoiceStatement.rebillSuffix
     , invoiceStatement.billingProfileCorrelatedCustomText1
     , invoiceStatement.billingProfileCorrelatedCustomText2
     , invoiceStatement.billingProfileCorrelatedCustomText3
     , invoiceStatement.billingProfileCorrelatedCustomText4
     , invoiceStatement.billingProfileCorrelatedCustomText5
     , invoiceStatement.billingProfileCorrelatedCustomText6
     , invoiceStatement.billingProfileCorrelatedCustomText7
     , invoiceStatement.billingProfileCorrelatedCustomText8
     , invoiceStatement.billingProfileCorrelatedCustomText9
     , invoiceStatement.billingProfileCorrelatedCustomText10
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock1
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock2
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock3
     , CAST(
  CASE
    WHEN credit.invoiceStatementTypeLookupID = 2 -- Credit - Reinstate
      THEN 1
    ELSE 0 END AS BIT
  )                                                                                     AS isReinstated
     , CAST(
  CASE
    WHEN credit.creditOfInvoiceStatementID IS NOT NULL THEN 1
    ELSE 0 END AS BIT
  )                                                                                     AS isCredited
     , invoiceStatement.invoiceStatementTemplateID
     , invoiceStatement.effectiveDate
     , invoiceStatement.creditOfInvoiceStatementID
     , invoiceStatement.rawInvoiceStatementNumber
     , invoiceStatement.invoiceStatementStatusLookupID
     , invoiceStatement.invoiceStatementDeliveryStatusLookupID
     , invoiceStatement.invoiceStatementMessageTemplateID
     , ISNULL(subtotals.lineItemTotal, 0)                                               AS 'lineItemTotal'
     , ISNULL(invoiceStatement.discountAmount, 0)                                       AS 'discountTotal'
     , ISNULL(invoiceStatement.surchargeAmount, 0)                                      AS 'surchargeTotal'
     , invoiceStatement.subtotal                                                        AS 'subtotal'
     , invoiceStatement.subtotal                                                        AS 'finalizedSubtotal'
     , ISNULL(invoiceStatement.taxAmount, 0)                                            AS 'taxTotal'
     , invoiceStatement.total                                                           AS 'total'
     , invoiceStatement.total                                                           AS 'finalizedTotal'
     , invoiceStatement.generalLedgerExportStatusLookupID
     , invoiceStatement.invoiceStatementDeliveryStatusLookupID                          AS newInvoiceStatementDeliveryStatusLookupID
     , CASE
         WHEN invoiceStatement.total <= invoicePayment.amountPaid
           THEN 1 -- Paid
         WHEN invoiceStatement.total > invoicePayment.amountPaid AND invoicePayment.amountPaid > 0
           THEN 2 -- Partial Paid
         ELSE
           3 -- Unpaid
  END                                                                                   AS invoiceStatementPaidStatusID
     , ISNULL(invoicePayment.paymentCount, 0)                                           AS paymentCount
     , ISNULL(invoicePayment.amountPaid, 0.00)                                          AS amountPaid
     , (ISNULL(invoiceStatement.total, 0.00) - ISNULL(invoicePayment.amountPaid, 0.00)) AS outstandingBalance
FROM BULLHORN1.BH_InvoiceStatement invoiceStatement WITH (NOLOCK)
       LEFT JOIN (
  SELECT invoiceStatementID,
         SUM(ISNULL(total, 0)) AS lineItemTotal
  FROM BULLHORN1.BH_InvoiceStatementLineItem WITH (NOLOCK)
  GROUP BY invoiceStatementID
) AS subtotals
                 ON subtotals.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN BULLHORN1.BH_InvoiceStatement credit WITH (NOLOCK)
                 ON credit.creditOfInvoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT
         invoiceStatementID AS 'invoiceStatementID', SUM(amount) AS 'amountPaid', COUNT(checkNumber) AS 'paymentCount'
  FROM BULLHORN1.BH_InvoicePayment invoicePayment WITH (NOLOCK)
  GROUP BY invoiceStatementID
) AS invoicePayment
                 ON invoicePayment.invoiceStatementID = invoiceStatement.invoiceStatementID
;
