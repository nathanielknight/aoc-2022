(require '[clojure.test :as t])

(defn parse-pair [s]
  (for [l (str/split-lines s)]
    (edn/read-string l)))

(defn parse-pairs [ps]
  (map parse-pair ps))

(defn load-input [fname]
  (-> fname
      slurp
      (str/split #"\n\n")
      parse-pairs))

(defmulti cmp-inorder (fn [x y] [(type x) (type y)]))
(defmethod cmp-inorder [java.lang.Long java.lang.Long] [x y]
  (compare x y))
(defmethod cmp-inorder [java.lang.Long clojure.lang.Seqable] [x y]
  (cmp-inorder [x] y))
(defmethod cmp-inorder[clojure.lang.Seqable java.lang.Long] [x y]
  (cmp-inorder x [y]))
(defmethod cmp-inorder
  [clojure.lang.Seqable clojure.lang.Seqable]
  [x y]
  (cond
    (and (empty? x) (empty? y)) 0
    (and (empty? x) (not (empty? y))) -1
    (and (empty? y) (not (empty? x))) 1 
    :else (case (cmp-inorder (first x) (first y))
      -1 -1
      1 1
      0 (cmp-inorder (subvec x 1) (subvec y 1)))))

(defn inorder [x y] (= -1 (cmp-inorder x y)))

(t/deftest test-cmp-inorder
  (let [cases [[1 2]
                  [1 [2]]
                  [[1] 2]
                  [[1] [1 2]]
                  [1 [2 2]]
                  [[1 1] [1 1 1]]
                  [[1 2 3] [1 3]]]]
    (t/is (every? #(apply inorder %) cases)))
  (let [cases [[2 1]
                      [[2] 1]
                      [2 [1]]
                      [[2] [1]]
                      [[1 1] [1]]
                      [[1 2] [1 1]]]]
    (t/is (every? #(not (apply inorder %)) cases))))

(t/run-tests)

(defn part-1-solution [] 
  (apply + (map-indexed
             #(if (apply inorder %2) 
                (inc %1)
                0)
             (load-input "input.txt"))))


(println "Part 1: " (part-1-solution))


(def divider-packets  [[[2]] [[6]]])

(defn part-2-packets []
  (->> "input.txt"
      (load-input)
      (apply concat)
      (concat divider-packets)))

(defn part-2-solution []
  (let [packets (into [] (sort inorder (part-2-packets)))
        idx1 (.indexOf packets [[2]])
        idx2 (.indexOf packets [[6]])]
    (println "Part 2: "
             ;; NB: increment because the problme starts indices at 1
      (* (inc idx1) (inc idx2)))))


(part-2-solution)
