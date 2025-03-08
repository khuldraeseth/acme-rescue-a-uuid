{-# LANGUAGE OverloadedStrings #-}

{- |
   Module      : Acme.UUID.V4
   Copyright   : (c) 2025 khuldraeseth
   License     : MIT
   Maintainer  : 28711596+khuldraeseth@users.noreply.github.com
   Stability   : experimental
   Portability : portable
-}
module Acme.UUID.V4 (rescueUUID) where

import Data.Function ((&))
import Data.Text qualified as T
import Data.UUID (UUID, fromText)
import Network.HTTP.Client (managerSetProxy, newManager, noProxy)
import Network.HTTP.Client.TLS (
    setGlobalManager,
    tlsManagerSettings,
 )
import Network.HTTP.Simple (httpSink)
import Safe (lastMay)
import Text.HTML.DOM (sinkDoc)
import Text.XML.Cursor (
    content,
    element,
    fromDocument,
    ($//),
    (&/),
    (&|),
 )

maybeFailWith :: (MonadFail m) => String -> Maybe a -> m a
maybeFailWith s = maybe (fail s) pure

{- | Rescue a  UUID.

@since 1.2.6
-}
rescueUUID :: IO UUID
rescueUUID = do
    manager <- newManager $ managerSetProxy noProxy tlsManagerSettings
    setGlobalManager manager

    doc <- httpSink "https://wasteaguid.info/" $ const sinkDoc
    let cursor = fromDocument doc
        contents =
            cursor
                $// element "h1"
                &/ content
                &| T.strip

    text <- lastMay contents & maybeFailWith "couldn't find UUID to rescue"
    fromText text & maybeFailWith ("couldn't parse UUID from " ++ T.unpack text)
