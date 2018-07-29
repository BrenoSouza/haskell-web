module HeapImpl (Heap, emptyHeap, heapEmpty, findHeap, insHeap, delHeap) where

  
data Heap a = EmptyHP | HP a Int (Heap a) (Heap a) deriving Show
  
--emptyHeap :: (Ord a) => Heap a
emptyHeap :: Heap a
emptyHeap = EmptyHP

--heapEmpty :: (Ord a) => Heap a -> Bool
heapEmpty :: Heap a -> Bool
heapEmpty EmptyHP = True
heapEmpty _ = False

findHeap :: (Ord a) => Heap a -> a
findHeap EmptyHP = error "findHeap: Empty Heap!"
findHeap (HP element _ left right) = element

rank :: (Ord a) => Heap a -> Int
rank EmptyHP = 0
rank (HP _ rank _ _ ) = rank

-- Swap children nodes if rank(right) > rank(left)
makeHP :: (Ord a) => a -> Heap a -> Heap a -> Heap a
makeHP x a b | rank a >= rank b = HP x (rank b + 1) a b
             | otherwise = HP x (rank a + 1) b a

-- O(log n) merge
merge :: (Ord a) => Heap a -> Heap a -> Heap a
merge heap EmptyHP = heap
merge EmptyHP heap = heap
merge heap1@(HP element1 _ left1 right1) heap2@(HP element2 _ left2 right2)
  | element1 <= element2 = makeHP element1 left1 (merge right1 heap2)
  | otherwise = makeHP element2 left2 (merge heap1 right2)

-- Merge Heap with root node containing element
insHeap :: (Ord a) => a -> Heap a -> Heap a
insHeap element heap = merge (HP element 1 EmptyHP EmptyHP) heap

-- Merge root childrens
delHeap :: (Ord a) => Heap a -> Heap a
delHeap EmptyHP = error "delHeap: Empty Heap!"
delHeap (HP element _ left right) = merge left right
