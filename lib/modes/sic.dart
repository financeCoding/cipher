library cipher_modes_sic;

import "dart:typed_data";

import "package:cipher/api.dart";
import "package:cipher/params/parameters_with_iv.dart";

/**
 * Implements the Segmented Integer Counter (SIC) mode on top of a simple
 * block cipher. This mode is also known as CTR mode.
 */
class SICBlockCipher implements BlockCipher {

  final BlockCipher underlyingCipher;
  
  Uint8List _iv;
  Uint8List _counter;
  Uint8List _counterOut;
  
  SICBlockCipher(this.underlyingCipher) {
    _iv = new Uint8List(blockSize);
    _counter = new Uint8List(blockSize);
    _counterOut = new Uint8List(blockSize);
  }

  String get algorithmName => "${underlyingCipher.algorithmName}/SIC";
  int get blockSize => underlyingCipher.blockSize;

  void reset() {
    _copy(_iv,_counter);
    underlyingCipher.reset();
  }

  void init(bool forEncryption, ParametersWithIV params) {
    _copy( params.iv, _iv );

    reset();

    underlyingCipher.init( true, params.parameters );
  }

  int processBlock( Uint8List inp, int inpOff, Uint8List out, int outOff ) {
    underlyingCipher.processBlock( _counter, 0, _counterOut, 0 );

    //
    // XOR the counterOut with the plaintext producing the cipher text
    //
    for( var i=0 ; i<_counterOut.lengthInBytes ; i++ ) {
      out[outOff+i] = _counterOut[i] ^ inp[inpOff+i];
    }

    // increment counter by 1.
    for( var i=_counter.lengthInBytes-1 ; i>=0 ; i-- )
    {
      var val = _counter[i];
      val++;
      _counter[i] = val;
      if( _counter[i]!=0 ) break;
    }
    //_printCounter();

    return _counter.lengthInBytes;
  }
  
  void _copy( Uint8List source, Uint8List dest ) {
    dest.setAll(0, source);
  }
  
  /*
  void _printCounter() {
    var sb = new StringBuffer();
    for( var i=0 ; i<_counter.length ; i++ ) {
      var val = _counter[i];
      if( val<16 ) {
        sb.write("0");
      } 
      sb.write(val.toRadixString(16));
    }
    print(sb.toString());
  }
  */
}