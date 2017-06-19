module Paths_haskellParser (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/nathaniel/.cabal/bin"
libdir     = "/home/nathaniel/.cabal/lib/x86_64-linux-ghc-7.10.3/haskellParser-0.1.0.0-7nSyThqbEp725ATOxMEt4Z"
datadir    = "/home/nathaniel/.cabal/share/x86_64-linux-ghc-7.10.3/haskellParser-0.1.0.0"
libexecdir = "/home/nathaniel/.cabal/libexec"
sysconfdir = "/home/nathaniel/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "haskellParser_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "haskellParser_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "haskellParser_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "haskellParser_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "haskellParser_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
