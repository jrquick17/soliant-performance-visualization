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
     , CASE
         WHEN invoiceStatement.deliveryMethodLookupID = 3 -- Email
           THEN CASE
                  WHEN emailBatch.batchStatusLookupID IN (1, 2) -- email is Initiated, Processing
                    THEN 6 -- Email Sending
                  WHEN exportBatch.batchStatusLookupID IN (1, 2) -- exportBatch is Initiated, Processing
                    THEN 5 -- Export Generating
                  WHEN exportBatch.batchStatusLookupID = 3 AND emailBatch.batchStatusLookupID = 3 -- Completed
                    THEN 3 -- Email sent
                  WHEN exportBatch.batchStatusLookupID = 4
                    THEN 4 -- Export Generation Failed
                  WHEN export.fileSize > 10485760 OR emailBatch.emailTooLarge = 1
                    THEN 9 -- Export is Too Large for Email
                  WHEN exportBatch.batchStatusLookupID = 3 AND emailBatch.batchStatusLookupID = 4
                    THEN 2 -- Email failed
                  WHEN invoiceStatement.isFinalized = 1 AND exportBatch.batchStatusLookupID = 3 AND
                       emailBatch.batchStatusLookupID IS NULL
                    THEN 2 -- Email Not Sent
                  ELSE 1 -- N/A
           END
         WHEN invoiceStatement.deliveryMethodLookupID = 1 --Print
           THEN CASE
                  WHEN exportBatch.batchStatusLookupID IN (1, 2) -- Initiated, Processing
                    THEN 5 -- Export Generating
                  WHEN exportBatch.batchStatusLookupID = 4
                    THEN 4 -- Failed
                  WHEN export.fileSize > 41943040
                    THEN 8 -- Export is Too Large for Download
                  WHEN exportBatch.batchStatusLookupID = 3
                    THEN 7 -- Ready to print
                  ELSE 1 -- N/A
           END
         WHEN invoiceStatement.deliveryMethodLookupID = 2 --Do not Print
           THEN 1 -- N/A
         ELSE 1 -- N/A
  END                                                                                   AS newInvoiceStatementDeliveryStatusLookupID
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
  SELECT exportBatch.invoiceStatementID, exportBatch.batchStatusLookupID
  FROM BULLHORN1.BH_InvoiceStatementExportBatch exportBatch WITH (NOLOCK)
         -- get latest invoiceStatementExportBatch based on dateLastModified or ID
         LEFT JOIN BULLHORN1.BH_InvoiceStatementExportBatch exportBatch2 WITH (NOLOCK)
                   ON exportBatch2.invoiceStatementID = exportBatch.invoiceStatementID
                     AND ((exportBatch2.dateLastModified > exportBatch.dateLastModified) OR
                          (exportBatch2.dateLastModified = exportBatch.dateLastModified AND
                           exportBatch2.invoiceStatementExportBatchID > exportBatch.invoiceStatementExportBatchID))
  WHERE exportBatch2.invoiceStatementExportBatchID IS NULL
) exportBatch ON exportBatch.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT export.invoiceStatementID, export.invoiceStatementExportID, export.fileSize
  FROM BULLHORN1.BH_InvoiceStatementExport export WITH (NOLOCK)
         -- get latest invoiceStatementExport based on dateLastModified or ID
         LEFT JOIN BULLHORN1.BH_InvoiceStatementExport export2 WITH (NOLOCK)
                   ON export2.invoiceStatementID = export.invoiceStatementID
                     AND ((export2.dateLastModified > export.dateLastModified) OR
                          (export2.dateLastModified = export.dateLastModified AND
                           export2.invoiceStatementExportID > export.invoiceStatementExportID))
  WHERE export2.invoiceStatementExportID IS NULL
) export ON export.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT export1.invoiceStatementID
       , CASE
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 3 THEN 1 ELSE NULL END)) >= 1 THEN 3
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 2 THEN 1 ELSE NULL END)) >= 1 THEN 2
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 1 THEN 1 ELSE NULL END)) >= 1 THEN 1
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 4 THEN 1 ELSE NULL END)) >= 1 THEN 4
    END as batchStatusLookupID
       , CASE
           WHEN (COUNT(CASE WHEN emailBatch.emailTooLarge = 0 THEN 1 ELSE NULL END)) >= 1 THEN 0
           WHEN (COUNT(CASE WHEN emailBatch.emailTooLarge = 1 THEN 1 ELSE NULL END)) >= 1 THEN 1
    END as emailTooLarge
       --Check if the emailBatch is completed for any export, then processing, then initiated and lastly if it failed for all attempts
  FROM BULLHORN1.BH_InvoiceStatementEmailBatch emailBatch WITH (NOLOCK)
         INNER JOIN BULLHORN1.BH_InvoiceStatementExport export1 WITH (NOLOCK)
                    ON export1.invoiceStatementExportID = emailBatch.invoiceStatementExportID
  GROUP BY export1.invoiceStatementID
) emailBatch ON emailBatch.invoiceStatementID = invoiceStatement.invoiceStatementID
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
  SELECT invoiceStatementID AS 'invoiceStatementID',
         SUM(amount)        AS 'amountPaid',
         COUNT(checkNumber) AS 'paymentCount'
  FROM BULLHORN1.BH_InvoicePayment invoicePayment WITH (NOLOCK)
  GROUP BY invoiceStatementID
) AS invoicePayment
                 ON invoicePayment.invoiceStatementID = invoiceStatement.invoiceStatementID
;
