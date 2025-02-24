#property library License
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern string lk = "0";

void dcl() {
    string lic="";
    string kstr="";
    if (lk != "0") {
        lic = lk;
        kstr = gk(AccountCompany(), asciiToHex(AccountName()), IntegerToString(AccountNumber()));
    } else {
        // default values
        lic = "A77261A3E4712DABA5CBD98F041424C5";
        kstr = gk("Recovery Trial", "Demo User", "100000000");
    }
    string t = decrypt(lic, kstr);
    if(t == NULL || StringLen(t) != 10) {
        Print("Invalid License, please add a valid license in the lk parameter");
        ExpertRemove();
        return;
    }
    datetime f = StringToTime(t);
    datetime c = TimeCurrent();
    datetime l = TimeLocal();
    if(f <= c || f <= l) {
        Print("Your license has expired, please add a new license in the lk parameter");
        ExpertRemove();
        return;
    }
}

string gk(string cn, string an, string anum) {
    int ix[20] = {16, 11, 4, 20, 8, 10, 6, 3, 1, 19, 18, 12, 2, 17, 5, 15, 7, 9, 14, 13};
    uchar accNameArr[]; 
    uchar comNameArr[];
    uchar accNumberArr[];
    StringToCharArray(cn, comNameArr);
    StringToCharArray(an, accNameArr);
    StringToCharArray(anum, accNumberArr);
    uchar key[60];
    for (int i=0; i<20; i++) {
        uchar com;
        uchar nam; 
        uchar num;
        int index = ix[i];
        if (ArraySize(comNameArr) <= index) {
            com = comNameArr[ArraySize(comNameArr)-1];
        } else {
            com = comNameArr[index];
        }
        if (ArraySize(accNameArr) <= index) {
            nam = accNameArr[ArraySize(accNameArr)-1];
        } else {
            nam = accNameArr[index];
        }
        if (ArraySize(accNumberArr) <= index) {
            num = accNumberArr[ArraySize(accNumberArr)-1];
        } else {
            num = accNumberArr[index];
        }
        key[i*3]=com;
        key[i*3+1]=nam;
        key[i*3+2]=num;
    }
    uchar dummy[] = {};
    uchar keyHash[];
    int res=CryptEncode(CRYPT_HASH_SHA256,key,dummy,keyHash);
    if (res <= 0) {
        Print("Cant calculate key");
        return NULL;
    }
    string strKey = ArrayToHex(keyHash);
    return strKey;
}

string asciiToHex(string asciiStr) {
   uchar accNameArr[];
   StringToCharArray(asciiStr, accNameArr);
   return ArrayToHex(accNameArr);
}

string ArrayToHex(uchar &arr[]) {
    string res="";
    int count=ArraySize(arr); 
    for(int i=0; i<count; i++) {
        res+=StringFormat("%.2X",arr[i]);
    }
    return res;
}
uchar toDecimal(uchar x) {
   if (x == 'A') {
      return 10;
   } else if (x == 'B') {
      return 11;
   } else if (x == 'C') {
      return 12;
   } else if (x == 'D') {
      return 13;
   } else if (x == 'E') {
      return 14;
   } else if (x == 'F') {
      return 15;
   }
   return x - '0';
}

void HexToArray(string hexStr, uchar &arr[]) {
    int count = StringLen(hexStr)/2;
    ArrayResize(arr, count);
    uchar hexChars[];
    StringToCharArray(hexStr, hexChars);
    for (int i=0; i < count; i++) {
        uchar x1 = toDecimal(hexChars[i*2]);
        uchar x2 = toDecimal(hexChars[i*2 + 1]);
        
        uchar c = x1*16 + x2;
        arr[i] = c; 
    }
}

string decrypt(string contentStr, string key) {
    uchar keyChars[];
    uchar contentChars[];
    uchar decryptedChars[];
    HexToArray(contentStr, contentChars);
    StringToCharArray(key, keyChars);
    int res = CryptDecode(CRYPT_AES256, contentChars, keyChars, decryptedChars);
    if (res <= 0) {
        Print("ERROR decripting: ", GetLastError());
        return NULL;
    }
    return CharArrayToString(decryptedChars);
}
