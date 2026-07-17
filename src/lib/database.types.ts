export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  entities: {
    Tables: {
      agent: {
        Row: {
          agent_kind: string | null
          id: string
        }
        Insert: {
          agent_kind?: string | null
          id: string
        }
        Update: {
          agent_kind?: string | null
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "agent_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      entity: {
        Row: {
          created_at: string
          created_by: string | null
          entity_type: string
          id: string
          notes: string | null
          updated_at: string
          updated_by: string | null
          working_label: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          entity_type: string
          id?: string
          notes?: string | null
          updated_at?: string
          updated_by?: string | null
          working_label: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          entity_type?: string
          id?: string
          notes?: string | null
          updated_at?: string
          updated_by?: string | null
          working_label?: string
        }
        Relationships: []
      }
      external_identifier: {
        Row: {
          created_at: string
          entity_id: string
          id: string
          namespace: string
          source_id: string | null
          value: string
        }
        Insert: {
          created_at?: string
          entity_id: string
          id?: string
          namespace: string
          source_id?: string | null
          value: string
        }
        Update: {
          created_at?: string
          entity_id?: string
          id?: string
          namespace?: string
          source_id?: string | null
          value?: string
        }
        Relationships: [
          {
            foreignKeyName: "external_identifier_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "external_identifier_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
        ]
      }
      item: {
        Row: {
          id: string
          item_kind: string | null
        }
        Insert: {
          id: string
          item_kind?: string | null
        }
        Update: {
          id?: string
          item_kind?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "item_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      place: {
        Row: {
          id: string
          place_kind: string | null
        }
        Insert: {
          id: string
          place_kind?: string | null
        }
        Update: {
          id?: string
          place_kind?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "place_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      source: {
        Row: {
          id: string
          reference: string | null
          retrieved_at: string | null
          source_kind: string
        }
        Insert: {
          id: string
          reference?: string | null
          retrieved_at?: string | null
          source_kind: string
        }
        Update: {
          id?: string
          reference?: string | null
          retrieved_at?: string | null
          source_kind?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  knowledge: {
    Tables: {
      claim: {
        Row: {
          asserted_by_agent_id: string | null
          created_at: string
          created_by: string | null
          id: string
          literal_value: Json | null
          notes: string | null
          object_entity_id: string | null
          predicate: string
          status: string
          subject_id: string
          supersedes_claim_id: string | null
          updated_at: string
          updated_by: string | null
        }
        Insert: {
          asserted_by_agent_id?: string | null
          created_at?: string
          created_by?: string | null
          id?: string
          literal_value?: Json | null
          notes?: string | null
          object_entity_id?: string | null
          predicate: string
          status?: string
          subject_id: string
          supersedes_claim_id?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Update: {
          asserted_by_agent_id?: string | null
          created_at?: string
          created_by?: string | null
          id?: string
          literal_value?: Json | null
          notes?: string | null
          object_entity_id?: string | null
          predicate?: string
          status?: string
          subject_id?: string
          supersedes_claim_id?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "claim_supersedes_claim_id_fkey"
            columns: ["supersedes_claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
        ]
      }
      claim_evidence: {
        Row: {
          claim_id: string
          created_at: string
          created_by: string | null
          excerpt: string | null
          id: string
          locator: string
          notes: string | null
          relationship: string
          source_id: string
        }
        Insert: {
          claim_id: string
          created_at?: string
          created_by?: string | null
          excerpt?: string | null
          id?: string
          locator: string
          notes?: string | null
          relationship: string
          source_id: string
        }
        Update: {
          claim_id?: string
          created_at?: string
          created_by?: string | null
          excerpt?: string | null
          id?: string
          locator?: string
          notes?: string | null
          relationship?: string
          source_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_evidence_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  entities: {
    Enums: {},
  },
  knowledge: {
    Enums: {},
  },
} as const

