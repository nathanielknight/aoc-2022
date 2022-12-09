(use 'clojure.test)

;;;; ----------------------------------------------
;;;; Parsing

(defn get-input-lines []
  (-> "input.txt"
      (slurp)
      (clojure.string/split-lines)))


(def initial-parser-state
  {:dirs {}
   :cwd []
   :input (get-input-lines)})


(defn is-command? [line]
  (= \$ (get line 0)))


(def is-not-command? (complement is-command?))

(deftest command-detection
  (is (is-command? "$ ls"))
  (is (is-command? "$ cd /"))
  (is (is-not-command? "dir foo"))
  (is (is-not-command? "12345 bar")))


(defn apply-cd [parser-state dirname]
  (case dirname
    ".." (update parser-state :cwd pop)
    "/" (assoc parser-state :cwd ["/"])
    (update parser-state :cwd conj dirname)))

(deftest apply-cd-test
  (is (= {:cwd [1]} (apply-cd {:cwd [1 2]} "..")))
  (is (= {:cwd [1 2]} (apply-cd {:cwd [1]} 2)))
  (is (= {:cwd ["/"]} (apply-cd {:cwd [1 2 3]} "/"))))


(defn parse-entry [e]
  (let [[fst snd] (clojure.string/split e #" ")]
    (case fst
      "dir" nil
      [snd (parse-long fst)])))

(deftest test-parse-entry
  (is (= nil (parse-entry "dir foo")))
  (is (= ["bar" 1] (parse-entry "1 bar"))))


(defn apply-entry [parser-state entry]
  (if (nil? entry)
    parser-state
    (assoc-in parser-state (concat [:dirs] (parser-state :cwd) [(first entry)])  (second entry))))

(deftest apply-entry-test
  (let [ps {:cwd ["/" "a" "b"] :dirs {}}]
    (is (= {"/" {"a" {"b" {"c" 1}}}} (:dirs (apply-entry ps ["c" 1]))))
    (is (= ps (apply-entry ps nil)))))

(defn apply-entries [parser-state entries]
  (reduce apply-entry parser-state entries))

(deftest apply-entries-test
  (is (= {"/" {"a" {"b" 1 "c" 2}}}
         (:dirs (apply-entries {:dirs {} :cwd ["/" "a"]}
                               [["b" 1] ["c" 2]])))))

(defn apply-ls [parser-state]
  (let [entries (take-while is-not-command? (:input parser-state))
        rest (drop-while is-not-command? (:input parser-state))
        p (assoc parser-state :input rest)]
    (apply-entries p (map parse-entry entries))))

(defn apply-cmd [parser-state]
  (let [cmd (first (parser-state :input))
        [_ cmd arg] (clojure.string/split cmd #" ")
        rest (rest (parser-state :input))
        p (assoc parser-state :input rest)]
    (case cmd
      "cd" (apply-cd p arg)
      "ls" (apply-ls p))))

(defn apply-cmds [parser-state]
  (loop [ps parser-state]
    (if (empty? (ps :input))
      ps
      (recur (apply-cmd ps)))))


;;;; ----------------------------------------------
;;;; Part 1 Analysis
(defn node-size [dir]
  (if (number? dir)
    dir
    (apply + (map node-size (vals dir)))))

(deftest node-size-test
  (is (= 1 (node-size 1)))
  (is (= 2 (node-size {"a" 2})))
  (is (= 3 (node-size {"a" 1 "b" {"c" 2}}))))


(defn dir-size [dir]
  (assert (map? dir) "dir-size should only be called on maps")
  (apply + (map node-size (vals dir))))

(deftest dir-size-test
  (is (= 1 (dir-size {"a" 1}))))

(defn total-dirs-size []
  (->> initial-parser-state
       (apply-cmds)
       (:dirs)
       (tree-seq map? vals)
       (filter map?)
       (map dir-size)
       (filter #(< % 100000))
       (apply +)))


;;;; ----------------------------------------------
;;;; Part 2 Analysis

(def total-disk-size 70000000)
(def required-disk-space 30000000)

(defn smallest-deletion-for-update []
  (let [loaded (apply-cmds initial-parser-state)
        used-space (dir-size (:dirs loaded))
        available-space (- total-disk-size used-space)
        must-free (- required-disk-space available-space)]
    (->> loaded
         (:dirs)
         (tree-seq map? vals)
         (filter map?)
         (map dir-size)
         (filter #(> % must-free))
         (apply min))))


;;;; ----------------------------------------------
;;;; Main

(run-tests)
(println "Part 1: " (total-dirs-size))
(println "Part 2: " (smallest-deletion-for-update))