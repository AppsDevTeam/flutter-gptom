enum GpTomEcrResultCode {
  /// 0
  /// CZ: Platba byla úspěšná.
  /// EN: Transaction was successful.
  ecrSuccess,

  /// -1
  /// CZ: Transakce selhala.
  /// EN: Transaction failed.
  ecrFailed,

  /// -2
  /// CZ: Chybné ID transakce - neodesláno nebo špatná hodnota.
  /// EN: Innvalid transaction ID - not sent or bad value.
  ecrTransactionIdInvalid,

  /// -3
  /// CZ: Transakce nenalezena. Tento kód je obvykle zaslán na Inquiry request a znamená, že můžete znovu zahájit transakci.
  /// EN: Transaction not found. This value is usually sent on Inquiry request and means, that you can initiate the transaction again.
  ecrTransactionNotFound,

  /// -4
  /// CZ: Transakce byla zamítnuta.
  /// EN: Transaction was declined.
  ecrTransactionDecline,

  /// -5
  /// CZ: Transakce již byla stornována.
  /// EN: Transaction was already cancelled.
  ecrTransactionAlreadyVoided,

  /// -6
  /// CZ: Neplatné parametry, zkontrolujte přítomnost nebo správný formát.
  /// EN: Invalid parameters, check the presence or correct format.
  ecrParameterInvalid,

  /// -7
  /// CZ: Chyba, uživatel není autorizován.
  /// EN: Error, user not authorized.
  ecrUnauthorized,

  /// -8
  /// CZ: Chyba, operace není povolena.
  /// EN: Error, operation is not allowed.
  ecrNotAllowed,

  /// -9
  /// CZ: Zásah ze strany uživatele je nezbytný v GP tom.
  /// EN: Input from user is needed in GP tom.
  ecrWrongStatus;

  static GpTomEcrResultCode? fromCode(int? code) {
    return switch (code) {
      0 => ecrSuccess,
      -1 => ecrFailed,
      -2 => ecrTransactionIdInvalid,
      -3 => ecrTransactionNotFound,
      -4 => ecrTransactionDecline,
      -5 => ecrTransactionAlreadyVoided,
      -6 => ecrParameterInvalid,
      -7 => ecrUnauthorized,
      -8 => ecrNotAllowed,
      -9 => ecrWrongStatus,
      _ => null,
    };
  }
}
