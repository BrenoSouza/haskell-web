module HeapImpl (Heap, test, emptyHeap, heapEmpty, findHeap, insHeap, delHeap, buildHeap, heapSort) where

  import qualified Data.Map.Strict as M

  data Heap a = EmptyHP Ordering | HP a Int Ordering (Heap a) (Heap a) deriving Show

  emptyHeap :: Ordering -> Heap a
  emptyHeap ordering = (EmptyHP ordering)

  heapEmpty :: Heap a -> Bool
  heapEmpty (EmptyHP _ ) = True
  heapEmpty _ = False

  findHeap :: (Ord a) => Heap a -> a
  findHeap (EmptyHP _ ) = error "findHeap: Empty Heap!"
  findHeap (HP element _ _ left right) = element

  rank :: (Ord a) => Heap a -> Int
  rank (EmptyHP _ ) = 0
  rank (HP _ rank _ _ _ ) = rank

  policy :: (Ord a) => Heap a -> Ordering
  policy (EmptyHP policy) =  policy
  policy (HP _ _ policy _ _) = policy


  -- Swap children nodes if rank(right) > rank(left)
  makeHP :: (Ord a) => a -> Heap a -> Heap a -> Heap a
  makeHP x a b | (policy a /= policy b) = error "make HP: diferent heap policies"
               | rank a >= rank b = HP x (rank b + 1) (policy a) a b
               | otherwise = HP x (rank a + 1) (policy b) b a

  -- O(log n) merge
  merge :: (Ord a) => Heap a -> Heap a -> Heap a
  merge heap (EmptyHP _ ) = heap
  merge (EmptyHP _ ) heap = heap
  merge heap1@(HP element1 _ policy1 left1 right1) heap2@(HP element2 _ policy2 left2 right2)
    | (policy heap1 /= policy heap2) = error "merge: diferent heap policies"
    | element1 `compare` element2 == policy1 = makeHP element1 left1 (merge right1 heap2)
    | otherwise = makeHP element2 left2 (merge heap1 right2)

  -- Merge Heap with root node containing element - O(log n)
  insHeap :: (Ord a) => a -> Heap a -> Heap a
  insHeap element heap = merge (HP element 1 policyhp (emptyHeap policyhp) (emptyHeap policyhp)) heap where
    policyhp = (policy heap)

  -- Merge root childrens - O(log n)
  delHeap :: (Ord a) => Heap a -> Heap a
  delHeap (EmptyHP _ ) = error "delHeap: Empty Heap!"
  delHeap (HP element _ _ left right) = merge left right

  -- O(n log n) build heap
  buildHeap :: (Ord a) => [a] -> Ordering -> Heap a
  buildHeap (x:xs) ordering = buildHeapAux xs (HP x 1 ordering (emptyHeap ordering) (emptyHeap ordering) )

  buildHeapAux :: (Ord a) => [a] -> Heap a -> Heap a
  buildHeapAux [] heap = heap
  buildHeapAux (x:xs) heap = buildHeapAux xs (insHeap x heap)

  -- O(n log n) sort list
  heapSort :: (Ord a) => [a] -> Ordering -> [a]
  heapSort list ordering = heapSortAux (buildHeap list ordering)

  heapSortAux :: (Ord a) => Heap a -> [a]
  heapSortAux heap | heapEmpty heap == True = []
                   | otherwise = (findHeap heap) : heapSortAux (delHeap heap)

  test :: [Int]      
  test = [1, 1, 1, 1, 1, 1]