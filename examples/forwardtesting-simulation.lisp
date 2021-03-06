;;;; forwardtesting-simulation.lisp

(in-package #:trading-core)

(setf logv:*log-output* nil)

;; Set the location of the historical data used in the simulation if different from the default.
;(setf *historical-data-path* "C:/Worden/TeleChart/Export/SP500_Components/")

;; Set the location where the analysis result template is located if different from default
;(setf *ui-template-path* #P"C:/Users/Jonathan/Lisp/projects/trading-core/trading-ui/templates/")

;; Set the location where the analysis results will be placed if different from default
;(setf *analysis-results-path* #P"C:/Users/Jonathan/Lisp/projects/trading-core/trading-ui/")

;; Load historical data and use it to compute "future" price data.
(defparameter *security-data* `((:msft . ,(compute-future-prc-data (load-event-data "MSFT" :data-format :bar)))
                                (:aapl . ,(compute-future-prc-data (load-event-data "AAPL" :data-format :bar)))))

(setf *agents*
      (list (make-instance 'adaptive-moving-avg-trend-following
                           :n-min 10 :n-max 55 :width-factor 1.5
                           :snr-factor .5 :security :msft)
            (make-instance 'adaptive-moving-avg-trend-following
                           :n-min 10 :n-max 55 :width-factor 1.5
                           :snr-factor .5 :security :aapl)
            (make-instance 'swing-mean-reversion
                           :max-allowed-breakout 1.25 :expected-width 5.0
                           :event-count 34 :security :msft)
            (make-instance 'swing-mean-reversion
                           :max-allowed-breakout 1.25 :expected-width 5.0
                           :event-count 34 :security :aapl)))

(defparameter *events* (sort (copy-list (union (cdr (assoc :msft *security-data*)) (cdr (assoc :aapl *security-data*))))
                             (lambda (x y)
                               (local-time:timestamp< (timestamp x) (timestamp y)))))

(run-simulation *events*)

(analyze *agents* *security-data*)

;; EOF
