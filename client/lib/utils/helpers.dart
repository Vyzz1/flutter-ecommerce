import 'dart:math';

import 'package:client/models/attribute.dart';
import 'package:client/models/attribute_value_input.dart';
import 'package:client/models/product.dart';
import 'package:client/models/product_variants.dart';

List<ProductVariants> generateVariants(
  List<Attribute> attributes,
  List<ProductVariants> existingVariants,
) {
  // Generate combinations of attribute values
  List<List<AttributeValue>> generateCombinations(
    List<Attribute> attributes,
    int currentIndex, {
    List<AttributeValue> currentCombination = const [],
  }) {
    if (currentIndex == attributes.length) {
      return [List<AttributeValue>.from(currentCombination)];
    }

    final currentAttribute = attributes[currentIndex];
    final combinations = <List<AttributeValue>>[];

    // Skip attributes with no values
    if (currentAttribute.values.isEmpty) {
      return generateCombinations(
        attributes,
        currentIndex + 1,
        currentCombination: currentCombination,
      );
    }

    for (final value in currentAttribute.values) {
      final newCombination = List<AttributeValue>.from(currentCombination)
        ..add(AttributeValue(attributeId: currentAttribute.id, value: value));

      final nextCombinations = generateCombinations(
        attributes,
        currentIndex + 1,
        currentCombination: newCombination,
      );
      combinations.addAll(nextCombinations);
    }

    return combinations;
  }

  // Create a key for a list of attribute values
  String createKey(List<AttributeValue> attributes) {
    final sortedAttrs = List<AttributeValue>.from(attributes)
      ..sort((a, b) => a.attributeId.compareTo(b.attributeId));

    return sortedAttrs
        .map((attr) => '${attr.attributeId}:${attr.value}')
        .join('-');
  }

  // Map existing variants by their attribute key
  final existingVariantMap = <String, ProductVariants>{};
  for (final variant in existingVariants) {
    final key = createKey(variant.attributes);
    existingVariantMap[key] = variant;
  }

  // Generate all possible combinations
  final attributeCombinations = generateCombinations(attributes, 0);

  // Create new variants list
  final newVariants = <ProductVariants>[];

  // First pass: Generate new variants without considering best parent
  final generatedCombinations = <List<AttributeValue>>[];
  for (final combination in attributeCombinations) {
    final key = createKey(combination);

    // If this exact combination already exists, keep it
    if (existingVariantMap.containsKey(key)) {
      newVariants.add(existingVariantMap[key]!);
    } else {
      generatedCombinations.add(
        combination,
      ); // Add combination for further processing
    }
  }

  print("Length of generatedCombinations: ${generatedCombinations.length}");

  // Second pass: Find best parent for each new combination
  for (final combination in generatedCombinations) {
    print("Inherited From Parent");
    final key = createKey(combination);

    // Try to find the best parent variant to inherit from
    List<ProductVariants> bestParents = [];
    int bestMatchCount = 0;

    for (final existingVariant in existingVariants) {
      // Count matching attributes
      int matchCount = 0;
      for (final attr in combination) {
        if (existingVariant.attributes.any(
          (a) =>
              a.attributeId == attr.attributeId && a.value.contains(attr.value),
        )) {
          matchCount++;
        }
      }

      // If this variant has more matches than our current best, reset the best list
      if (matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestParents = [existingVariant]; // Reset the list to the current best
      } else if (matchCount == bestMatchCount) {
        bestParents.add(existingVariant); // Add to the best list if it matches
      }
    }

    // Select the last "best parent" if available
    ProductVariants? selectedParent;
    if (bestParents.isNotEmpty) {
      selectedParent = bestParents.last; // Choose the last best parent
    }

    // Create new variant, inheriting from selected parent if found
    if (selectedParent != null) {
      newVariants.add(
        ProductVariants(
          id:
              'new-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}-${Random().nextInt(1000)}',
          attributes: combination,
          price: selectedParent.price,
          basePrice: selectedParent.basePrice,
          stock: selectedParent.stock,
          discount: selectedParent.discount,
          // images: selectedParent.images,
        ),
      );
    } else {
      newVariants.add(
        ProductVariants(
          id:
              'new-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}-${Random().nextInt(1000)}',
          attributes: combination,
          price: "0",
          basePrice: "0",
          discount: 0,
          stock: 0,
          images: [],
        ),
      );
    }
  }

  return newVariants;
}

List<AttributeValueInput> mapProductToAttributes(Product product) {
  final List<AttributeValueInput> attributeValues = [];

  for (var variant in product.variants) {
    for (var attribute in variant.attributes) {
      String attributeId = attribute.attributeId;
      String attributeName = attribute.name!;
      String attributeValue = attribute.value;

      Attribute attributeObj = Attribute(id: attributeId, name: attributeName);

      var existingInput = attributeValues.firstWhere(
        (input) => input.attribute.id == attributeId,
        orElse: () => AttributeValueInput(attribute: attributeObj, values: []),
      );

      if (!existingInput.values.contains(attributeValue)) {
        existingInput.values.add(attributeValue);
      }

      if (!attributeValues.contains(existingInput)) {
        attributeValues.add(existingInput);
      }
    }
  }

  return attributeValues;
}
