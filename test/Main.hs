module Main (main) where

import Acme.UUID.V4 (rescueUUID)
import Data.Functor (void)

main :: IO ()
main = do
    void rescueUUID
