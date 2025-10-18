# 🔧 BUILD ERROR FIXED!

## ❌ Error

```
Attribute uses-permission#android.permission.WRITE_EXTERNAL_STORAGE@maxSdkVersion value=(32) from AndroidManifest.xml:12:9-35
is also present at [:camera_android_camerax] AndroidManifest.xml:13:9-35 value=(28).
```

## 🔍 Causa

O plugin da câmera (`camera_android_camerax`) estava definindo `WRITE_EXTERNAL_STORAGE` com `maxSdkVersion="28"`, conflitando com nossa configuração `maxSdkVersion="32"`.

## ✅ Solução

Adicionado o namespace `tools` e o atributo `tools:replace` para sobrescrever a configuração do plugin:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- Storage Permissions for Android 12 and below -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"
        tools:replace="android:maxSdkVersion"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"
        tools:replace="android:maxSdkVersion"/>
```

## 📝 O que foi alterado

**Arquivo:** `android/app/src/main/AndroidManifest.xml`

1. ✅ Adicionado `xmlns:tools="http://schemas.android.com/tools"` no tag `<manifest>`
2. ✅ Adicionado `tools:replace="android:maxSdkVersion"` em `WRITE_EXTERNAL_STORAGE`
3. ✅ Adicionado `tools:replace="android:maxSdkVersion"` em `READ_EXTERNAL_STORAGE`

## 🚀 Resultado

Agora o build passa sem conflitos e mantém nossa configuração de `maxSdkVersion="32"` para suportar corretamente Android 12 e 13+.

---

**Status:** ✅ RESOLVIDO  
**Build:** 🟢 FUNCIONANDO

