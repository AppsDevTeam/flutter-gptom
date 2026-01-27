import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gptom/gptom.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GP tom demo', theme: ThemeData(useMaterial3: true), home: const DemoHome());
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  bool _isDev = true;
  bool _initialized = false;

  final _amountCtrl = TextEditingController(text: '100');
  final _tipCtrl = TextEditingController(text: '');
  final _clientIdCtrl = TextEditingController(text: '');
  final _originRefCtrl = TextEditingController(text: 'flutter_ref_1');
  final _originTxCtrl = TextEditingController(text: '');

  String? _transactionId; // získané z register

  GpTomPaymentMethod? _paymentMethod = GpTomPaymentMethod.card;
  bool _printByPaymentApp = true;
  bool _tipCollect = false;

  GpTomCancelMode _cancelMode = GpTomCancelMode.lastTransaction;

  StreamSubscription? _saleSub;
  StreamSubscription? _refundSub;
  StreamSubscription? _cancelSub;
  StreamSubscription? _batchSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _detailSub;

  final List<String> _log = [];
  GpTomResult? _lastCallResult;

  @override
  void initState() {
    super.initState();

    // typed results -> UI log
    _saleSub = GpTomManager.saleResults.listen((r) {
      _addLog('EVENT SALE: ${_fmt(r)}\nDATA: ${r.data}');
    });

    /*_refundSub = GpTomManager.refundResults.listen((r) {
      _addLog('EVENT REFUND: ${_fmt(r)}\nDATA: ${r.data}');
    });*/

    _cancelSub = GpTomManager.cancelResults.listen((r) {
      _addLog('EVENT STORNO: ${_fmt(r)}\nDATA: ${r.data}');
    });

    _batchSub = GpTomManager.closeBatchResults.listen((r) {
      _addLog('EVENT CLOSE_BATCH: ${_fmt(r)}\nDATA: ${r.data}');
    });

    _stateSub = GpTomManager.stateResults.listen((r) {
      _addLog('EVENT STATE: ${_fmt(r)}\nDATA: ${r.data}');
    });

    _detailSub = GpTomManager.detailResults.listen((r) {
      _addLog('EVENT DETAIL: ${_fmt(r)}\nDATA: ${r.data}');
    });

    // optional raw events (debug)
    // GpTomManager.events.listen((e) => _addLog('RAW EVENT: $e'));
  }

  @override
  void dispose() {
    _saleSub?.cancel();
    _refundSub?.cancel();
    _cancelSub?.cancel();
    _batchSub?.cancel();
    _stateSub?.cancel();
    _detailSub?.cancel();

    _amountCtrl.dispose();
    _tipCtrl.dispose();
    _clientIdCtrl.dispose();
    _originRefCtrl.dispose();
    _originTxCtrl.dispose();
    super.dispose();
  }

  void _addLog(String s) {
    setState(() {
      _log.insert(0, '[${DateTime.now().toIso8601String()}] $s');
      if (_log.length > 200) _log.removeLast();
    });
  }

  String _fmt(GpTomResult r) => 'code=${r.code.name}, msg=${r.message ?? ""},';

  int? _intOrNull(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  String? _strOrNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _call(Future<GpTomResult> Function() fn) async {
    final res = await fn();
    setState(() => _lastCallResult = res);
    _addLog('CALL: ${_fmt(res)}');
  }

  bool get _hasTxId => (_transactionId != null && _transactionId!.isNotEmpty);

  // ---------- Actions ----------

  Future<void> _init() async {
    try {
      await GpTomManager.init(
        GpTomInitOptions(isDevelopment: _isDev, debugLogs: true, iosRedirectUrl: 'adtgptom://callback'),
      );
      setState(() {
        _initialized = true;
      });
      _addLog('INIT OK (dev=$_isDev)');
    } catch (e) {
      _addLog('INIT FAILED: $e');
    }
  }

  Future<void> _isInstalled() async {
    await _call(() => GpTomManager.isInstalled());
  }

  Future<void> _register() async {
    final req = GpTomRegisterRequest(
      originReferenceNum: _strOrNull(_originRefCtrl),
      clientId: _strOrNull(_clientIdCtrl),
    );

    final res = await GpTomManager.register(req);
    setState(() => _lastCallResult = res);
    _addLog('CALL REGISTER: ${_fmt(res)}');

    if (res.code == GpTomResultCode.ok && res.data != null) {
      final tid = res.data!.transactionId;

      _originTxCtrl.text = tid ?? "";

      setState(() {
        _transactionId = tid;
      });
      _addLog('REGISTER -> transactionId=$_transactionId');
    }
  }

  Future<void> _sale() async {
    if (!_hasTxId) {
      _addLog('ERROR: call register first (missing transactionId)');
      return;
    }
    final amount = _intOrNull(_amountCtrl);
    if (amount == null || amount <= 0) {
      _addLog('ERROR: invalid amount');
      return;
    }

    final req = GpTomTransactionRequest.sale(
      transactionId: _transactionId!,
      amount: amount,
      originReferenceNum: _strOrNull(_originRefCtrl),
      clientId: _strOrNull(_clientIdCtrl),
      printByPaymentApp: _printByPaymentApp,
      tipCollect: _tipCollect,
      tipAmount: _tipCollect ? null : _intOrNull(_tipCtrl),
      currencyCode: null,
      paymentMethod: _paymentMethod,
    );

    await _call(() => GpTomManager.transaction(req));
  }

  Future<void> _refund() async {
    final origin = _strOrNull(_originTxCtrl);
    if (origin == null) {
      _addLog('ERROR: originTransactionId is required for refund');
      return;
    }

    final amount = _intOrNull(_amountCtrl);
    if (amount == null || amount <= 0) {
      _addLog('ERROR: invalid amount');
      return;
    }

    final reg = await GpTomManager.register(
      GpTomRegisterRequest(originReferenceNum: _strOrNull(_originRefCtrl), clientId: _strOrNull(_clientIdCtrl)),
    );
    final newTxId = reg.data?.transactionId;

    setState(() => _lastCallResult = reg);
    _addLog('CALL REGISTER (for refund): ${_fmt(reg)}');

    if (reg.code != GpTomResultCode.ok || newTxId == null || newTxId.isEmpty) {
      _addLog('ERROR: register for refund failed');
      return;
    }

    setState(() => _transactionId = newTxId);
    _addLog('REFUND will use new transactionId=$newTxId, originTransactionId=$origin');

    /*final req = GpTomTransactionRequest.refund(
      transactionId: newTxId,
      amount: amount,
      originReferenceNum: _strOrNull(_originRefCtrl),
      clientId: _strOrNull(_clientIdCtrl),
      originTransactionId: origin,
      paymentMethod: _paymentMethod,
    );

    await _call(() => GpTomManager.refund(req));*/
  }

  Future<void> _storno() async {
    final origin = _strOrNull(_originTxCtrl);
    if (origin == null) {
      _addLog('ERROR: originTransactionId is required (transaction to cancel)');
      return;
    }

    final reg = await GpTomManager.register(
      GpTomRegisterRequest(originReferenceNum: _strOrNull(_originRefCtrl), clientId: _strOrNull(_clientIdCtrl)),
    );
    final newTxId = reg.data?.transactionId;

    setState(() => _lastCallResult = reg);
    _addLog('CALL REGISTER (for storno): ${_fmt(reg)}');

    if (reg.code != GpTomResultCode.ok || newTxId == null || newTxId.isEmpty) {
      _addLog('ERROR: register for storno failed');
      return;
    }

    setState(() => _transactionId = newTxId);
    _addLog('STORNO will use new transactionId=$newTxId, originTransactionId=$origin');

    final req = GpTomTransactionRequest.storno(
      transactionId: newTxId,
      cancelMode: _cancelMode,
      originTransactionId: origin,
      clientId: _strOrNull(_clientIdCtrl),
      paymentMethod: _paymentMethod,
    );

    await _call(() => GpTomManager.cancel(req));
  }

  Future<void> _state() async {
    if (!_hasTxId) {
      _addLog('ERROR: call register first (missing transactionId)');
      return;
    }

    await _call(() => GpTomManager.getState(_transactionId!));
  }

  Future<void> _detail() async {
    if (!_hasTxId) {
      _addLog('ERROR: call register first (missing transactionId)');
      return;
    }

    await _call(() => GpTomManager.getDetail(_transactionId!));
  }

  Future<void> _closeBatch() async {
    await _call(() => GpTomManager.closeBatch());
  }

  Future<void> _getPending() async {
    await _call(() => GpTomManager.getPending());
  }

  Future<void> _clearPending() async {
    await _call(() => GpTomManager.clearPending());
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final last = _lastCallResult;

    return Scaffold(
      appBar: AppBar(title: const Text('GP tom Example')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('DEV')),
                              ButtonSegment(value: false, label: Text('PROD')),
                            ],
                            selected: {_isDev},
                            onSelectionChanged: (s) {
                              setState(() {
                                _isDev = s.first;
                                _initialized = false;
                              });
                              _addLog('ENV changed -> dev=$_isDev (re-init needed)');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(onPressed: _init, child: Text(_initialized ? 'Init ✓' : 'Init')),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // transactionId display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Text('transactionId: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(child: SelectableText(_transactionId ?? '—')),
                            IconButton(
                              onPressed: () {
                                setState(() => _transactionId = null);
                                _addLog('transactionId cleared in UI');
                              },
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear transactionId',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount (minor units)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _tipCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tip (minor units, optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _originRefCtrl,
                            decoration: const InputDecoration(
                              labelText: 'originReferenceNum',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _clientIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'clientId (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _originTxCtrl,
                      decoration: const InputDecoration(
                        labelText: 'originTransactionId (for storno/refund)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<GpTomPaymentMethod>(
                            initialValue: _paymentMethod,
                            isExpanded: true,
                            items: GpTomPaymentMethod.values
                                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                                .toList(),
                            onChanged: (v) => setState(() => _paymentMethod = v),
                            decoration: const InputDecoration(labelText: 'paymentMethod', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<GpTomCancelMode>(
                            isExpanded: true,
                            initialValue: _cancelMode,
                            items: GpTomCancelMode.values
                                .map((e) => DropdownMenuItem(value: e, child: Text('${e.name} (${e.code})')))
                                .toList(),
                            onChanged: (v) => setState(() => _cancelMode = v ?? GpTomCancelMode.lastTransaction),
                            decoration: const InputDecoration(labelText: 'cancelMode', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            value: _printByPaymentApp,
                            onChanged: (v) => setState(() => _printByPaymentApp = v),
                            title: const Text('printByPaymentApp'),
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            value: _tipCollect,
                            onChanged: (v) => setState(() => _tipCollect = v),
                            title: const Text('tipCollect'),
                            dense: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(onPressed: _isInstalled, child: const Text('isInstalled')),
                        OutlinedButton(onPressed: _register, child: const Text('register')),
                        FilledButton(onPressed: _sale, child: const Text('SALE')),
                        // FilledButton(onPressed: _refund, child: const Text('REFUND')),
                        FilledButton.tonal(onPressed: _storno, child: const Text('STORNO')),
                        FilledButton.tonal(onPressed: _state, child: const Text('STATE')),
                        FilledButton.tonal(onPressed: _detail, child: const Text('DETAIL')),
                        FilledButton.tonal(onPressed: _closeBatch, child: const Text('CLOSE BATCH')),
                        OutlinedButton(onPressed: _getPending, child: const Text('getPending')),
                        OutlinedButton(onPressed: _clearPending, child: const Text('clearPending')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _ResultCard(last: last),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _log.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SelectableText(_log[i], style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatefulWidget {
  final GpTomResult? last;
  const _ResultCard({required this.last});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _showData = false;

  @override
  Widget build(BuildContext context) {
    final last = widget.last;
    final theme = Theme.of(context);

    if (last == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Last call result: —', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      );
    }

    final isOk = last.code == GpTomResultCode.ok;

    String dataStr;
    try {
      dataStr = (last.data == null) ? 'null' : last.data.toString();
    } catch (_) {
      dataStr = '<unprintable>';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Last call result',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOk ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    last.code.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOk ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _kv('message', last.message ?? ''),

            const SizedBox(height: 8),

            // Data section
            Row(
              children: [
                Expanded(
                  child: Text('data', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => setState(() => _showData = !_showData),
                  child: Text(_showData ? 'Hide' : 'Show'),
                ),
              ],
            ),

            if (_showData) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: SelectableText(
                    dataStr,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    if (v.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: SelectableText(v, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
