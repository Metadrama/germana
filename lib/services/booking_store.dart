import 'package:flutter/foundation.dart';
import 'package:germana/models/booking_record.dart';
import 'package:germana/models/ride_model.dart';

class BookingStore extends ChangeNotifier {
  BookingStore({List<LedgerEntry> initialLedgerEntries = const []})
      : _ledgerEntries = List<LedgerEntry>.from(initialLedgerEntries);

  final Map<String, BookingRecord> _bookings = {};
  final List<LedgerEntry> _ledgerEntries;

  List<BookingRecord> get bookings => _bookings.values.toList();

  List<LedgerEntry> get ledgerEntries =>
      List<LedgerEntry>.unmodifiable(_ledgerEntries);

  BookingRecord? getBooking(String id) => _bookings[id];

  void replaceLedgerEntries(
    List<LedgerEntry> entries, {
    bool notify = false,
  }) {
    _ledgerEntries
      ..clear()
      ..addAll(entries);
    if (notify) {
      notifyListeners();
    }
  }

  // Creates the booking record in `initiated` state.
  BookingRecord initiate({
    required String rideId,
    required String passengerId,
    required double escrowAmount,
  }) {
    final id = 'booking_${DateTime.now().millisecondsSinceEpoch}';
    final booking = BookingRecord(
      id: id,
      rideId: rideId,
      passengerId: passengerId,
      status: BookingRecordStatus.initiated,
      escrowAmount: escrowAmount,
    );
    _bookings[id] = booking;
    notifyListeners();
    return booking;
  }

  // Transition to `escrowHeld` after payment UI.
  void pay(String bookingId, {String? description, String? rideRoute}) {
    final booking = _bookings[bookingId];
    if (booking == null) return;
    if (booking.status != BookingRecordStatus.initiated) return;

    final updated = booking.copyWith(
      status: BookingRecordStatus.escrowHeld,
      holdAt: DateTime.now(),
    );
    _bookings[bookingId] = updated;

    // Mutate the mock ledger.
    _ledgerEntries.insert(0, LedgerEntry(
      id: 'txn_escrow_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.escrowHold,
      amount: -booking.escrowAmount,
      date: DateTime.now(),
      description: description ?? 'Tempat dijamin — simpanan escrow',
      rideRoute: rideRoute,
    ));

    notifyListeners();
  }

  // Driver accepts the booking, moving it to `accepted`.
  void accept(String bookingId) {
    final booking = _bookings[bookingId];
    if (booking == null) return;
    
    final allowedStates = [BookingRecordStatus.escrowHeld, BookingRecordStatus.pendingDriver];
    if (!allowedStates.contains(booking.status)) return;

    final updated = booking.copyWith(
      status: BookingRecordStatus.accepted,
      acceptedAt: DateTime.now(),
    );
    _bookings[bookingId] = updated;

    notifyListeners();
  }

  // Escrow times out, auto-transition to `timedOut` which triggers a refund.
  void timeout(String bookingId, {String? description, String? rideRoute}) {
    final booking = _bookings[bookingId];
    if (booking == null) return;

    final allowedStates = [BookingRecordStatus.escrowHeld, BookingRecordStatus.pendingDriver];
    if (!allowedStates.contains(booking.status)) return;

    final updated = booking.copyWith(
      status: BookingRecordStatus.timedOut,
      timeoutAt: DateTime.now(),
    );
    _bookings[bookingId] = updated;

    // Timeout triggers a refund.
    refund(bookingId, description: description ?? 'Automatik bayaran balik — tamat masa', rideRoute: rideRoute);
  }

  // Manual or automatic refund for a booking.
  void refund(String bookingId, {String? description, String? rideRoute}) {
    final booking = _bookings[bookingId];
    if (booking == null) return;

    // Allow refunds if not already refunded or completed
    if (booking.status == BookingRecordStatus.refunded || 
        booking.status == BookingRecordStatus.completed) {
      return; 
    }

    final updated = booking.copyWith(
      status: BookingRecordStatus.refunded,
      refundAt: DateTime.now(),
    );
    _bookings[bookingId] = updated;

    // Mutate the mock ledger to refund the escrow amount.
    _ledgerEntries.insert(0, LedgerEntry(
      id: 'txn_refund_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.refund,
      amount: booking.escrowAmount,
      date: DateTime.now(),
      description: description ?? 'Bayaran balik',
      rideRoute: rideRoute,
    ));

    notifyListeners();
  }
}
