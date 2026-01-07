class CategoriesModel {
  int? categoriesId;
  String? categoriesName;
  String? categoriesImage;
  String? categoriesDate;

  CategoriesModel({
    this.categoriesId,
    this.categoriesName,
    this.categoriesImage,
    this.categoriesDate,
  });

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    categoriesId = json['categories_id'];
    categoriesName = json['categories_name'];
    categoriesImage = json['categories_image'];
    categoriesDate = json['categories_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categories_id'] = categoriesId;
    data['categories_name'] = categoriesName;
    data['categories_image'] = categoriesImage;
    data['categories_date'] = categoriesDate;
    return data;
  }
}
