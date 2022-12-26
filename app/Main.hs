module Main (main) where

import Lib hiding (noSortByFolder, noSortByName, noToplevel)
import Options.Applicative
import Data.Semigroup ((<>))

data CliArgs = CliArgs {
    path :: String,
    noSortByFolder :: Bool,
    noSortByName :: Bool,
    noToplevel :: Bool,
    ignoreFile :: String 
}

cliArgs :: Parser CliArgs 
cliArgs = CliArgs 
    <$> argument str (metavar "PATH") 
    <*> switch (long "noSortByFolder" <> help "Whether to place folders before files") 
    <*> switch (long "noSortByName" <> help "Whether to sort files by their name")
    <*> switch (long "noToplevel" <> help "Whether to include top-level folder")
    <*> strOption (long "ignoreFile" <> metavar "IGNOREFILE" <> help "Ignore file" <> value "")

main :: IO ()
main = execute =<< execParser opts
  where
    opts = info (cliArgs <**> helper)
      ( fullDesc
     <> progDesc "Generate a file tree"
     <> header "ftgen - a file tree generator" ) 

transformArgs :: CliArgs -> IO Args 
transformArgs cliArgs = do 
    newFiles <- if (ignoreFile cliArgs) /= "" 
        then do 
            contents <- readFile $ ignoreFile cliArgs 
            return $ lines contents
        else return [] 
    return (Args (not $ noSortByFolder cliArgs) (not $ noSortByName cliArgs) (noToplevel cliArgs) newFiles)

execute :: CliArgs -> IO ()
execute args = do 
    transformedArgs <- transformArgs args 
    genTree (path args) (Just transformedArgs)
