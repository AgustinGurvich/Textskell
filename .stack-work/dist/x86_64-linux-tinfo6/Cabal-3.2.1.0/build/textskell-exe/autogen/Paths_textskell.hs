{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_textskell (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/bin"
libdir     = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/lib/x86_64-linux-ghc-8.10.3/textskell-0.1.0.0-47VsG97mdkBe5iz3SVeFR-textskell-exe"
dynlibdir  = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/lib/x86_64-linux-ghc-8.10.3"
datadir    = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/share/x86_64-linux-ghc-8.10.3/textskell-0.1.0.0"
libexecdir = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/libexec/x86_64-linux-ghc-8.10.3/textskell-0.1.0.0"
sysconfdir = "/home/agustin/Documents/Textskell/.stack-work/install/x86_64-linux-tinfo6/c361a95cd13dfedffd8781d68cc77af364099fdbc4f571fdcbd975d984d2cedd/8.10.3/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "textskell_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "textskell_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "textskell_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "textskell_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "textskell_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "textskell_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
