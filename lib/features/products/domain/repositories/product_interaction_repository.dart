abstract class ProductInteractionRepository {
  Future<void> recordInteraction({
    required String productId,
    required String interactionType,
  });
}
