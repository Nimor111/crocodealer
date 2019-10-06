{- | Configurations through the @config.toml@ file@.
-}

module Crocodealer.Config
       ( Repo (..)
       , Config (..)
       , loadConfig
       ) where

import Toml (TomlCodec, (.=))
import qualified Toml

import Crocodealer.Core.Label as Label

newtype Repo = Repo
    { unRepo :: Text
    } deriving (Show)

-- | TOML Codec for the 'Repo' data type.
repoCodec :: TomlCodec Repo
repoCodec = Toml.dimap unRepo Repo $ Toml.text "repo"

data Config = Config
    { configUsername            :: !(Maybe Text)
    , configRepository          :: !(Maybe Text)
    , configLabelRules          :: ![Label.LabelRule]
    , configIgnoredRepositories :: ![Repo]
    } deriving (Show)

-- | TOML Codec for the 'Config' data type.
configCodec :: TomlCodec Config
configCodec = Config
    <$> Toml.dioptional (Toml.text "username") .= configUsername
    <*> Toml.dioptional (Toml.text "repository") .= configRepository
    <*> Toml.list Label.labelRuleCodec "labelRule" .= configLabelRules
    <*> Toml.list repoCodec "ignoredRepository" .= configIgnoredRepositories

-- | Loads the @config.toml@ file.
loadConfig :: MonadIO m => m Config
loadConfig = Toml.decodeFile configCodec "config.toml"
