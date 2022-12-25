module Lib
    ( genTree,
      Args(Args)
    ) where

import System.Directory
import Data.List 
import Data.List.Split

-- TODO:
-- Configuration (ignore files, change style, sorting, etc) 
-- .ftgenignore
-- Instant download for any platform via curl? 
-- Testing
-- Readme status icons
-- Custom icon sets given they can be integrated via http/file

-- Default config 
-- Order by folder 
-- After that order by letter

-- Combines two paths - TODO: shorten name
combinePath :: String -> String -> String 
combinePath a b = a ++ "/" ++ b

-- Sorts files according to preferences
sortFiles :: (Bool, Bool) -> File -> File 
sortFiles _ (File name) = File name 
sortFiles opts (Folder name files) = case opts of 
	(True, True) -> Folder name (sort files) 
	(True, False) -> Folder name (sortFolders files) 
	(False, True) -> Folder name (sortNames files) 
	(False, False) -> Folder name files 

sortFolders :: [File] -> [File]
sortFolders files = sortBy compareFolder files 

compareFolder :: File -> File -> Ordering
compareFolder (File _) (Folder _ _) = GT 
compareFolder (Folder _ _) (File _) = LT

sortNames :: [File] -> [File] 
sortNames files = sortBy compareName files 

compareName :: File -> File -> Ordering 
compareName (File a) (File b) = compare a b 
compareName (Folder a _) (Folder b _) = compare a b

-- Removes from list until occurence of delimeter
removeUntil :: (Eq a) => a -> [a] -> [a]
removeUntil _ [] = []
removeUntil delim (x:xs) = if (x == delim)
	then xs 
	else removeUntil delim xs

-- getExt gets the file's extension
getExt :: String -> Maybe String
getExt path = case rawext of 
	[] -> Nothing 
	_ -> Just ('.' : rawext)
	where rawext = removeUntil '.' path

-- File represents a folder or file
data File = File String | Folder String [File] 

instance Eq File where 
	File a == File b = a == b 
	Folder a _ == Folder b _ = a == b 
	_ == _ = False

instance Ord File where 
	compare (File a) (File b) = compare a b 
	compare (Folder a _) (Folder b _) = compare a b 
	compare (File _) (Folder _ _) = GT 
	compare (Folder _ _) (File _) = LT

notNothing :: Maybe a -> Bool 
notNothing (Just _) = True 
notNothing Nothing = False

combineDefined :: [Maybe a] -> [a] 
combineDefined [] = [] 
combineDefined (x:xs) = case x of 
	(Just a) -> a : (combineDefined xs)
	Nothing -> combineDefined xs

-- Parse transforms a path into a File object
parse :: [String] -> String -> String -> IO (Maybe File) 
parse ignoreFiles _ "." = do 
	currDir <- getCurrentDirectory 
	parse ignoreFiles "." $ "../" ++ (last $ splitOn "/" currDir)
parse ignoreFiles workDir path = do
	let combinedPath = workDir `combinePath` path 
	-- workDir ./../ftgen
	-- combinedPath ./../ftgen/dist-newstyle
	-- ignoreFiles dist-newstyle
	if combinedPath `elem` (map (combinePath workDir) ignoreFiles) then return Nothing	
	else do 
		directory <- doesDirectoryExist combinedPath 
		if directory 
			then do 
				-- IO String
				-- Need to list the cumulative path
				files <- listDirectory combinedPath 
				-- putStrLn $ intercalate " " files 
				let parsedPath = if isInfixOf "../" path then (last $ splitOn "../" path) else path 
				-- Folder String (String -> IO File) [String] -> [IO File]
				subFiles <- sequence $ map (parse ignoreFiles combinedPath) files
				return $ Just (Folder parsedPath (combineDefined subFiles))
			else return $ Just (File path)
		
-- Gets the filetype icon
getIcon :: String -> String 
getIcon ext = case ext of  
	".hs" -> ""
	".rs" -> ""
	".java" -> ""
	".c" -> ""
	".cpp" -> ""
	".r" -> ""
	_ -> ""

-- Generates the file display name
genName :: File -> String 
genName (File name) = (getIcon name) ++ " " ++ name 
genName (Folder name _) = "📁" ++ " " ++ name

-- Generates the file line
genLine :: Int -> File -> String 
genLine level file = 
	let prefix = concat $ take (level - 1) (repeat "│  ") in
	let stick = if level > 0 then "├─" else "" in 
	prefix ++ stick ++ (genName file) ++ "\n" 

-- Recursive utility for display function
recur :: Int -> File -> String 
recur level file = 
	case file of 
		File name -> genLine level (File name) 
		Folder name files -> 
			let childrenText = concat $ map (recur $ level + 1) files 
			    folderText = genLine level (Folder name []) in  
			folderText ++ childrenText
	

-- Generates the display string for a file tree
display :: Bool -> File -> String
display _ (File name) = genName $ File name 
display noToplevel (Folder name files) = case noToplevel of 
	False -> recur 0 (Folder name files) 
	True -> concat $ map (recur 0) files 

-- GenTree extra options
data Args = Args {
	sortByFolder :: Bool,
	sortByName :: Bool,
	noToplevel :: Bool,
	ignoreFiles :: [String] 
}

-- Default GenTree options
defaultArgs :: Args 
defaultArgs = Args {
	sortByFolder = True,
	sortByName = True,
	noToplevel = False,
	ignoreFiles = []
}

-- Generates the file tree and pipes to output 
genTree :: String -> Maybe Args -> IO () 
genTree path Nothing = genTree path (Just defaultArgs)
genTree path (Just args) = do 
	maybefile <- parse (ignoreFiles args) "." path 
	case maybefile of 
		Nothing -> putStrLn "failed" 
		(Just file) -> do 
			putStrLn $ display (noToplevel args) $ sortFiles (sortByFolder args, sortByName args) file 
	
