# Ararat-Synapse
This is updated repository. Docs and demos included
Original SVN repository could be found here svn://svn.code.sf.net/p/synalist/code.

Improved version of the great Synapse library, fixes:
- Added Disconnected processing and property
- Change variables scope mainly to private from protected
- SockCheck and ExceptCheck added, it works in Linux more stable
- GetSendTimeout and SetSendTimeout added
- Added different exception classes to improve processing
- LastError processing improved
- TBlockSocket.CanWrite rewritten
- Added FPC compilation defines
- Buffers changed from AnsiString to TSynaBytes and TBytes and from PAnsiChar to PByte
- Added const modifictors to the functions parameters where nedded
- Added ULTIBO support, source is here: https://github.com/bravesoftdz/AraratSynapse
- iOS support improved
- LDAP support improved
