String formatPrice(num price) {
  if (price % 1 == 0) {
    return price.toInt().toString();
  } else {
    return price.toStringAsFixed(2);
  }
}

