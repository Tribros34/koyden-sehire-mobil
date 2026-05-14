package products

import (
	"encoding/json"
	"time"
)

type Product struct {
	ID             string    `db:"id" json:"id"`
	FarmerID       string    `db:"farmer_id" json:"farmer_id"`
	CategoryID     string    `db:"category_id" json:"category_id"`
	Title          string    `db:"title" json:"title"`
	Description    string    `db:"description" json:"description"`
	Price          float64   `db:"price" json:"price"`
	Unit           string    `db:"unit" json:"unit"`
	City           string    `db:"city" json:"city"`
	District       string    `db:"district" json:"district"`
	Village        string    `db:"village" json:"village"`
	Status         string    `db:"status" json:"status"`
	PreviousStatus *string   `db:"previous_status" json:"previous_status,omitempty"`
	StockStatus    string    `db:"stock_status" json:"stock_status"`
	AdminNote      *string   `db:"admin_note" json:"admin_note,omitempty"`
	CreatedAt      time.Time `db:"created_at" json:"created_at"`
	UpdatedAt      time.Time `db:"updated_at" json:"updated_at"`
}

type ProductImage struct {
	ID        string    `db:"id" json:"id"`
	ProductID string    `db:"product_id" json:"product_id"`
	ImageURL  string    `db:"image_url" json:"url"`
	SortOrder int       `db:"sort_order" json:"sort_order"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
}

type PublicProductRow struct {
	ID                    string          `db:"id"`
	FarmerID              string          `db:"farmer_id"`
	CategoryID            string          `db:"category_id"`
	Title                 string          `db:"title"`
	Description           string          `db:"description"`
	Price                 float64         `db:"price"`
	Unit                  string          `db:"unit"`
	City                  string          `db:"city"`
	District              string          `db:"district"`
	Village               string          `db:"village"`
	Status                string          `db:"status"`
	StockStatus           string          `db:"stock_status"`
	CreatedAt             time.Time       `db:"created_at"`
	UpdatedAt             time.Time       `db:"updated_at"`
	ImagesJSON            json.RawMessage `db:"images"`
	DisplayName           string          `db:"display_name"`
	IsVerified            bool            `db:"is_verified"`
	IsFoundingFarmer      bool            `db:"is_founding_farmer"`
	FarmerProfileImageURL *string         `db:"profile_image_url"`
	FarmerCity            string          `db:"farmer_city"`
	FarmerDistrict        string          `db:"farmer_district"`
	PublicPhone           *string         `db:"public_phone"`
	CategoryName          string          `db:"category_name"`
	CategorySlug          string          `db:"category_slug"`
	ParentCategoryID      *string         `db:"parent_category_id"`
	ParentCategoryName    *string         `db:"parent_category_name"`
	ParentCategorySlug    *string         `db:"parent_category_slug"`
}

type PublicProduct struct {
	ID          string       `json:"id"`
	Title       string       `json:"title"`
	Description string       `json:"description"`
	Price       float64      `json:"price"`
	Unit        string       `json:"unit"`
	City        string       `json:"city"`
	District    string       `json:"district"`
	Village     string       `json:"village"`
	Status      string       `json:"status"`
	StockStatus string       `json:"stock_status"`
	CreatedAt   time.Time    `json:"created_at"`
	Images      []ImageItem  `json:"images"`
	Category    CategoryInfo `json:"category"`
	Farmer      FarmerInfo   `json:"farmer"`
}

type ImageItem struct {
	URL       string `json:"url"`
	SortOrder int    `json:"sort_order"`
}

type CategoryInfo struct {
	ID     string      `json:"id"`
	Name   string      `json:"name"`
	Slug   string      `json:"slug"`
	Parent *ParentInfo `json:"parent,omitempty"`
}

type ParentInfo struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Slug string `json:"slug"`
}

type FarmerInfo struct {
	ID               string  `json:"id"`
	DisplayName      string  `json:"display_name"`
	City             string  `json:"city"`
	District         string  `json:"district"`
	IsVerified       bool    `json:"is_verified"`
	IsFoundingFarmer bool    `json:"is_founding_farmer"`
	ProfileImageURL  *string `json:"profile_image_url"`
	PublicPhone      *string `json:"public_phone,omitempty"`
}
