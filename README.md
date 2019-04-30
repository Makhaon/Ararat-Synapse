# Ararat-Synapse
This is a clone of an SVN repository at svn://svn.code.sf.net/p/synalist/code. It had been cloned by http://svn2github.com/ , but the service was since closed. Please read a closing note on my blog post: http://piotr.gabryjeluk.pl/blog:closing-svn2github . If you want to continue synchronizing this repo, look at https://github.com/gabrys/svn2github 

Fixes:
- Improved version of the great Synapse library.
- Added Disconnected processing and property
- Change variables scope mainly to private from protected
- SockCheck and ExceptCheck added, it works in Linux more stable
- GetSendTimeout and SetSendTimeout added
- Added different exception classes to improve processing
- LastError processed processing improved
- TBlockSocket.CanWrite rewritten
- Added FPC compilation defines
- Buffers changed from AnsiString to TSynaBytes and TBytes and from PAnsiChar to PByte
- Added const modifictors to the functions parameters where nedded
- Added ULTIBO support, source is here: https://github.com/bravesoftdz/AraratSynapse
- iOS support improved
- LDAP support improved
